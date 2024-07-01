import cv2
import numpy as np
from numba import njit, prange


def closet_power_of_2(x: int):
    return int(np.power(2, np.ceil(np.log2(x))))


def pad_array_power_of_2(image: np.ndarray, constant_value: int = 0):

    bgra = cv2.cvtColor(image, cv2.COLOR_BGR2BGRA)

    pad_offset_cols = closet_power_of_2(bgra.shape[1]) - bgra.shape[1]
    padded = np.pad(
        bgra,
        ((0, 0), (0, pad_offset_cols), (0, 0)),
        "constant",
        constant_values=constant_value,
    )
    pad_offset_rows = closet_power_of_2(bgra.shape[0]) - bgra.shape[0]
    padded = np.pad(
        padded,
        ((0, pad_offset_rows), (0, 0), (0, 0)),
        "constant",
        constant_values=constant_value
    )

    return padded


@njit
def window_bgra(
    padded_bgra: np.ndarray,
    window_size: int
):

    windowed_frame = np.lib.stride_tricks.sliding_window_view(
        padded_bgra, (window_size, window_size, 4)
    )[::window_size, ::window_size].copy()

    windowed_frame = windowed_frame.reshape(
        (
            windowed_frame.shape[0],
            windowed_frame.shape[1],
            window_size,
            window_size,
            4,  # bgra
        )
    )
    return windowed_frame


@njit(fastmath=True, parallel=True)
def sort_windowed_bgrabgra(
    windowed_frame: np.ndarray,
    window_size: int,
    wpr_padded: int,
    wpc_padded: int,
    out_arr: np.ndarray
):
    # 4 is elements per window (r, g, b, a)

    windowed_frame = windowed_frame.reshape(
        (
            wpr_padded * wpc_padded,
            window_size * window_size,
            4,
        )
    )

    per_row_offset = wpr_padded * window_size * window_size

    for row in prange(wpc_padded):
        for col in prange(wpr_padded):
            out_arr[
                col
                + per_row_offset * row: per_row_offset * (row + 1): wpr_padded
            ] = windowed_frame[col + row * wpr_padded]


@njit(fastmath=True, parallel=True)
def sort_windowed_bbggrraa(
    windowed_frame: np.ndarray, out_arr: np.ndarray
):
    size = windowed_frame[0].flatten().shape[0]
    rounded = closet_power_of_2(size)

    for row in prange(windowed_frame.shape[0]):
        total = row * rounded
        for col in prange(windowed_frame.shape[1]):
            out_arr[
                col + total: size + total: windowed_frame.shape[1]
            ] = windowed_frame[row][col].flatten()
