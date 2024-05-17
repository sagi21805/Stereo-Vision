import cv2
import numpy as np
import ctypes
from numba import njit

DATA_TYPES = [ctypes.c_uint8, ctypes.c_uint32, ctypes.c_float]

def ptr_to_numpy(ptr: int, dtype: int, shape: tuple):
    global DATA_TYPES
    data_pointer = ctypes.cast(ptr, ctypes.POINTER(DATA_TYPES[dtype]))
    return np.ctypeslib.as_array(data_pointer, shape=shape)

def write_ptr(ptr: int, dtype: int, shape: tuple):
    cv2.imwrite("ptr.png", ptr_to_numpy(ptr, dtype, shape))

@njit
def repeat_elements(array, times):
    return np.repeat(array, times)

@njit(fastmath = True)
def closet_power_of_2(num: int):
    return int(np.power(2, np.ceil(np.log2(num))))

