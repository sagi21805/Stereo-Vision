import cv2
import numpy as np
import ctypes

WINDOWS = [
    np.zeros((2864, 1924), dtype=np.uint8),
    np.zeros((2864, 1924), dtype=np.uint8),
]   

def get_camera(index) -> cv2.VideoCapture:
    cap = cv2.VideoCapture(index)
    cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter.fourcc(*"MJPG"))
    return cap

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

def write_img(name, img):
    cv2.imwrite(name, img)

def show_ptr(ptr: int, rows, cols):
    data_pointer = ctypes.cast(ptr, ctypes.POINTER(ctypes.c_float))
    arr = np.ctypeslib.as_array(data_pointer, shape = (rows, cols))
    print(arr)
    cv2.imshow("map", arr)
    
