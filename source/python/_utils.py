import cv2
import numpy as np

def get_camera(index: int) -> cv2.VideoCapture:
    return cv2.VideoCapture(index)

def get_frame():
    x = cv2.VideoCapture(0)
    x.read()

    