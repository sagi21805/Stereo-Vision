import numpy as np
import cv2
from source.camera.cam_settings import CamSettings
from source.camera.cam_parameters import CamParameters


class Camera:
    def __init__(
        self,
        index: int,
        settings: CamSettings,
        parameters: CamParameters
    ):

        self.index = index
        self.cap = settings.initialize_cap(index)
        self.parameters = parameters
        self.frame = np.empty(0)
        self.warm()

    def get_frame(self):
        success, self.frame = self.cap.read()
    
    def write_frame(self):
        cv2.imwrite(f"assets/cam {self.index}.png", self.frame)

    def warm(self):
        [self.get_frame() for _ in range(60)]
            

    def set_exposure(self, exposure: int):
        self.cap.set(cv2.CAP_PROP_EXPOSURE, exposure)

    def set_auto_exposure(self, val: bool):
        self.cap.set(cv2.CAP_PROP_AUTO_EXPOSURE, 3 - (not val).__int__() * 2)
