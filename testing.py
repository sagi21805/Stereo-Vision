import time
import cv2

import numpy as np
from numba import prange, njit

def repeat_elements(array, times):
    repeated = np.repeat(array, times)
    interleaved = np.vstack((repeated, repeated)).reshape((-1,), order='F')
    return interleaved

# Example usage:


arr = np.array([[[1,   2,  3,  4], [5,   6,  7,  8], [9,  10, 11, 12], [13, 14, 15, 16], [1,   2,  3,  4], [5,   6,  7,  8]], 
                [[17, 18, 19, 20], [21, 22, 23, 24], [25, 26, 27, 28], [29, 30, 31, 32], [17, 18, 19, 20], [21, 22, 23, 24]]], dtype = np.uint8)

image = cv2.imread("data/im1-min.jpeg")

def prepare_arr(image: np.ndarray):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2BGRA)
    image = cv2.resize(image, (1280, 720))
    return image

@njit(fastmath = True)
def window_interleave(image: np.ndarray, window_size):
    windowed_arr = np.lib.stride_tricks \
                .sliding_window_view(image, (window_size, window_size, 4)) \
                [::window_size, ::window_size][0].copy()
    c = np.empty((windowed_arr.size, ), dtype=windowed_arr.dtype)
    for i in prange(windowed_arr.shape[0]):
        c[i::windowed_arr.shape[0]] = windowed_arr[i].flatten()
    return c.copy()



a = window_interleave(arr, 2)
print(a)
