import numpy as np
import cv2
from cam_settings import CamSettings

class Camera:
    def __init__(
        self, index, settings: CamSettings
    ):
        
        self.index = index
        if settings.fake == "":
            self.cap = settings.initialize_cap(index)
            self.warm()

        else:
            self.cap = cv2.VideoCapture()


    def get_frame(self):
        success, frame = self.cap.read()
        return frame if success else np.empty((0, ))

    def warm(self):
        for _ in range(10):
            self.get_frame()

    def set_exposure(self, exposure: int):
        self.cap.set(cv2.CAP_PROP_EXPOSURE, exposure)

    def set_auto_exposure(self, val: bool):
        self.cap.set(cv2.CAP_PROP_AUTO_EXPOSURE, 3 - (not val).__int__() * 2)
