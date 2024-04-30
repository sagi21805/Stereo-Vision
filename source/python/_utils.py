import cv2
import numpy as np

def get_camera(index: int) -> cv2.VideoCapture:
    return cv2.VideoCapture(index)

def read_image(path: str):
    return cv2.imread(path)

    