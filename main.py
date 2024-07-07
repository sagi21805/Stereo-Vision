from source.camera import Camera, CamParameters, CamSettings
import numpy as np
import cv2
import algorithms
from numba import prange, njit
from time import sleep, perf_counter_ns

cam = Camera(0, CamSettings(brightness=-10), CamParameters())
cam2 = Camera(2, CamSettings(brightness=-10), CamParameters())

b, g, r = cv2.split(cam.frame)


while True:

    cam.write_frame()
    b, g, r = cv2.split(cam.frame)
    cam.get_frame()

    integral = algorithms.IntegralImage(b)
    s = perf_counter_ns()    
    c = integral.sliding_window_multi_threshold(2, 3)
    e = perf_counter_ns()
    print("t:", (e - s) / 10**9)

    s = perf_counter_ns()
    d = algorithms.sliding_window_multi_threshold(b, 2, 3)
    e = perf_counter_ns()
    print("t2:", (e - s) / 10**9)

    # print((c-d).astype(np.uint32).sum())
    # print(np.array_equal(c, d))

    cv2.imwrite(f"assets/{cam.index}c.jpeg", c)
    cv2.imwrite(f"assets/{cam.index}d.jpeg", d)
    # # print((e - s) / 10  **9)
    sleep(0.15)

    
