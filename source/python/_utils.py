import cv2
import numpy as np

def get_camera(index: int) -> cv2.VideoCapture:
    return cv2.VideoCapture(index)

def read_image(path: str):
    return cv2.imread(path)

#notice on this device (orange pi), there is a size limit - currently using only images of max size 
# (1280, 800) - also camera image size!
def get_window_view(img: np.ndarray, window_size: int):
    if img.ndim == 3:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = cv2.resize(img, (1280, 800))   
    return np.lib.stride_tricks.sliding_window_view(img, (window_size, window_size)).flatten().copy()
        

def get_test_arr():
    img =np.array([[0,  1,  2,  3,  4,  5,  6,  7,  8,  9],
                    [10, 11, 12, 13, 14, 15, 16, 17, 18, 19],
                    [20, 21, 22, 23, 24, 25, 26, 27, 28, 29],
                    [30, 31, 32, 33, 34, 35, 36, 37, 38, 39], 
                    [40, 41, 42, 43, 44, 45, 46, 47, 48, 49], 
                    [50, 51, 52, 53, 54, 55, 56, 57, 58, 59],
                    [60, 61, 62, 63, 64, 65, 66, 67, 68, 69], 
                    [70, 71, 72, 73, 74, 75, 76, 77, 78, 79], 
                    [80, 81, 82, 83, 84, 85, 86, 87, 88, 89], 
                    [90, 91, 92, 93, 94, 95, 96, 97, 98, 99]], dtype=np.uint8)
    return img

