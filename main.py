from source.camera import Camera, CamParameters, CamSettings
import numpy as np
import cv2
import algorithms.algorithms as algs
from numba import prange, njit
from time import sleep, perf_counter_ns
import custom_algs
import numpy
cam = Camera(0, CamSettings(brightness=-10), CamParameters())
cam2 = Camera(2, CamSettings(brightness=-10), CamParameters())

b, g, r = cv2.split(cam.frame)


@njit(fastmath=True, parallel = True)
def func(img: np.ndarray, block_size: tuple[int, int], thresh):
    blocked = numpy.lib.stride_tricks.sliding_window_view(img, (block_size, block_size))
    new = np.zeros((blocked.shape[0], blocked.shape[1]), np.uint8)
    for i in prange(len(blocked)):
        for j in prange(len(blocked[0])):
            if np.sum(blocked[i][j]) > thresh:
                new[i][j] = 255
    return new


while True:

    obj = algs.MyClass(42)

# Call a method to get a value
    print(obj.get_value())  # This should print 42  
