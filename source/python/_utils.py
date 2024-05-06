import cv2
import numpy as np
import ctypes

WINDOWS = [
    np.zeros((2864, 1924), dtype=np.uint8),
    np.zeros((2864, 1924), dtype=np.uint8),
]


def get_camera(index: int) -> cv2.VideoCapture:
    return cv2.VideoCapture(index)


def read_image(path: str):
    return cv2.imread(path)


def get_window_view(img: np.ndarray, window_size: int, window_number: int):
    global WINDOWS
    if img.ndim == 3:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    WINDOWS[window_number] = np.lib.stride_tricks.sliding_window_view(
        img, (window_size, window_size)
    )[::window_size, ::window_size].copy()
    return WINDOWS[window_number]


def get_test_arr(window_number):
    global WINDOWS
    WINDOWS[window_number] = np.arange(100).reshape((10, 10)).astype(np.uint8)
    return WINDOWS[window_number]

