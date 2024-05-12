import cv2
import numpy as np
import ctypes

DATA_TYPES = [
    ctypes.c_uint8,
    ctypes.c_float
]


def ptr_to_numpy(ptr: int, data_type: int, shape: tuple):
    global DATA_TYPES
    data_pointer = ctypes.cast(ptr, ctypes.POINTER(DATA_TYPES[data_type]))
    return np.ctypeslib.as_array(data_pointer, shape = shape)

def write_ptr(ptr: int, data_type: int, shape: tuple):
    cv2.imwrite("ptr.png", ptr_to_numpy(ptr, data_type, shape))
    
def repeat_elements(array, times):
    return np.repeat(array, times)
