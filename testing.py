import time
import cv2
import math
import numpy as np
from numba import prange, njit
np.set_printoptions(threshold=np.inf)

def repeat_elements(array, times):
    repeated = np.repeat(array, times)
    interleaved = np.vstack((repeated, repeated)).reshape((-1,), order='F')
    return interleaved

# Example usage:


arr = np.array([[[1,   2,  3,  4], [5,   6,  7,  8], [9,  10, 11, 12], [13, 14, 15, 16], [1,   2,  3,  4], [5,   6,  7,  8]], 
                [[17, 18, 19, 20], [21, 22, 23, 24], [25, 26, 27, 28], [29, 30, 31, 32], [17, 18, 19, 20], [21, 22, 23, 99]],
                [[1,   2,  3,  4], [5,   6,  7,  8], [9,  10, 11, 12], [13, 14, 15, 16], [1,   2,  3,  4], [5,   6,  7,  8]],
                [[17, 18, 19, 20], [21, 22, 23, 24], [25, 26, 27, 28], [29, 30, 31, 32], [17, 18, 19, 20], [21, 22, 23, 100]],
                [[1,   2,  3,  4], [5,   6,  7,  8], [9,  10, 11, 12], [13, 14, 15, 16], [1,   2,  3,  4], [5,   6,  7,  8]],
                [[17, 18, 19, 20], [21, 22, 23, 24], [25, 26, 27, 28], [29, 30, 31, 32], [17, 18, 19, 20], [21, 22, 23, 101]],
                [[1,   2,  3,  4], [5,   6,  7,  8], [9,  10, 11, 12], [13, 14, 15, 16], [1,   2,  3,  4], [5,   6,  7,  8]],
                [[17, 18, 19, 20], [21, 22, 23, 24], [25, 26, 27, 28], [29, 30, 31, 32], [17, 18, 19, 20], [21, 22, 23, 101]]], dtype = np.uint8)

image = cv2.imread("data/im1-min.jpeg")

def prepare_arr(image: np.ndarray):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2BGRA)
    image = cv2.resize(image, (1280, 720))
    return image

@njit(fastmath = True, parallel = True)
def window_interleave(image: np.ndarray, window_size: int):
    windowed_arr: np.ndarray = np.lib.stride_tricks \
                .sliding_window_view(image, (window_size, window_size, 4)) \
                [::window_size, ::window_size].copy()
    windowed_arr = windowed_arr.reshape((windowed_arr.shape[0], windowed_arr.shape[1],window_size,window_size,4))
    print(windowed_arr.shape)

    size = windowed_arr[0].flatten().shape[0]
    size2 = int(closet_power_of_2(size)) - size
    c = np.zeros((windowed_arr.size + (windowed_arr.shape[0] * size2), ), dtype=np.uint8)
    for j in prange(windowed_arr.shape[0]):
        for i in prange(windowed_arr.shape[1]):
            c[i+j*(size+size2):size*(j+1)+j*size2:windowed_arr.shape[1]] = windowed_arr[j][i].flatten()
        c[i+j*size]
    
    return c

@njit(fastmath = True)
def closet_power_of_2(num: int):
    return np.power(2, np.ceil(np.log2(num)))


print(closet_power_of_2(1280))

# while True:


t = time.time()
a = window_interleave(arr, 2)
print(a)
print(time.time() - t)
print(a[:65])