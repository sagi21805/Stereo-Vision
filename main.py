from source.camera import Camera, CamParameters, CamSettings
import numpy as np
import cv2
from numba import prange, njit
from time import sleep, perf_counter_ns
import custom_algs

cam = Camera(0, CamSettings(brightness=-10), CamParameters())
cam2 = Camera(2, CamSettings(brightness=-10), CamParameters())

b, g, r = cv2.split(cam.frame)



while True:

    cam.write_frame()
    b, g, r = cv2.split(cam.frame)

    s = perf_counter_ns()    
    cam.get_frame()
    e = perf_counter_ns()
    b = custom_algs.window_multi_threshold(b, 2, 6)
    g = custom_algs.window_multi_threshold(g, 2, 6)
    r = custom_algs.window_multi_threshold(r, 2, 6)
    print((e - s) / 10**9)

    # print((e - s) / 10  **9)
    sleep(0.1)

    cv2.imwrite(f"assets/{cam.index}b.jpeg", b)
    cv2.imwrite(f"assets/{cam.index}g.jpeg", g)
    cv2.imwrite(f"assets/{cam.index}r.jpeg", r)
    cv2.imwrite(f"assets/{cam.index}s.jpeg", b + g + r)
