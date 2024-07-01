import numpy as np
from numpy import ndarray


class CamParameters():

    def __init__(
        self,
        center: ndarray[np.int32, np.int32],
        fov: ndarray[np.float32, np.float32],
        angle_pixel_ratio: ndarray[np.float32, np.float32]
    ) -> None:

        self.center = center
        self.fov = fov
        self.angle_pixel_ratio = angle_pixel_ratio

    def __init__(self) -> None:

        self.center = np.empty(2, np.int32)
        self.fov = np.empty(2, np.float32)
        self.angle_pixel_ratio = np.empty(2, np.float32)
