import cv2
import numpy as np
import ctypes
from numba import njit, prange

DATA_TYPES = [
    ctypes.c_uint8,
    ctypes.c_uint16 ,
    ctypes.c_uint32, 
    ctypes.c_float
    ]


def ptr_to_numpy(ptr: int, dtype: int, shape: tuple):
    global DATA_TYPES
    data_pointer = ctypes.cast(ptr, ctypes.POINTER(DATA_TYPES[dtype]))
    return np.ctypeslib.as_array(data_pointer, shape=shape)


def write_ptr(ptr: int, dtype: int, shape: tuple):
    cv2.imwrite("ptr.png", ptr_to_numpy(ptr, dtype, shape))


@njit(parallel=True)
def repeat_elements(array, times):
    return np.repeat(array, times)


@njit(fastmath=True)
def closet_power_of_2(num: int):
    return int(np.power(2, np.ceil(np.log2(num))))

def pad_array(bgra: np.ndarray):
    pad_offset_cols = (
        closet_power_of_2(bgra.shape[1]) - bgra.shape[1]
    )
    padded = np.pad(
        bgra,
        ((0, 0), (0, pad_offset_cols), (0, 0)),
        "constant",
        constant_values=255,
    )
    pad_offset_rows = (
        closet_power_of_2(bgra.shape[0]) - bgra.shape[0]
    )
    padded = np.pad(
        padded,
        ((0, pad_offset_rows), (0, 0), (0, 0)),
        "constant",
        constant_values=255,
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
    window_size: int
    ):

    elements_per_window = 4  # b, g, r, a

    bgrabgra = np.empty(
        (
            windowed_frame.size // elements_per_window,
            elements_per_window,
        ),
        dtype=np.uint8,
    )

    windowed_frame = windowed_frame.reshape(
        (
            windowed_frame.shape[0] * windowed_frame.shape[1],
            window_size * window_size,
            elements_per_window,
        )
    )

    for window in prange(windowed_frame.shape[0]):
        bgrabgra[
            window : bgrabgra.shape[0] : windowed_frame.shape[0]
        ] = windowed_frame[window]
    
    return bgrabgra

@njit(fastmath=True, parallel=True)
def sort_windowed_bbggrraa(
    bgrabgra: np.ndarray,
    window_size: int,
    windows_per_row: int, 
    windows_per_col: int
):

    bbggrraa = np.empty(
        (bgrabgra.size,),
        dtype=np.uint8,
    )

    for window_element in prange(window_size * window_size):
        for row in prange(windows_per_col):
            for col in prange(windows_per_row):
                total_row_elements = (
                    windows_per_row * 4 # 4 -> elements per pixel (b, g, r, a)
                )
                bbggrraa[
                    col
                    + (row + window_element * windows_per_col)
                    * total_row_elements : (
                        (row + 1) + window_element * windows_per_col
                    )
                    * total_row_elements : windows_per_row
                ] = bgrabgra[
                    col
                    + (row + window_element * windows_per_col)
                    * windows_per_row
                ]
    
    return bbggrraa

