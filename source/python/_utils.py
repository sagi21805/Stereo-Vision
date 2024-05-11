import cv2
import numpy as np
import ctypes

def write_ptr(ptr: int, img_rows: int, img_cols: int):
    data_pointer = ctypes.cast(ptr, ctypes.POINTER(ctypes.c_float))
    arr = np.ctypeslib.as_array(data_pointer, shape = (img_rows, img_cols))
    cv2.imwrite("ptr.png", arr)
    
