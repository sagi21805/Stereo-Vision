from cam_settings import CamSettings
from camera import Camera
from _utils import closet_power_of_2
import array_tricks as tricks
import numpy as np
import cv2

class StereoCam(Camera):

    def __init__(self,
                index: int, 
                settings: CamSettings, 
                window_size: int, 
                elements_per_pixel: int = 4
                ) -> None:
        
        super().__init__(index, settings)

        self.update_frame()
        self.windowed = np.empty((0, ))
        self.bgrabgra = np.empty((closet_power_of_2(settings.frame_width)
                                * closet_power_of_2(settings.frame_height) , 
                                elements_per_pixel))
        
        self.bbggrraa = np.empty((closet_power_of_2(settings.frame_width)
                                * closet_power_of_2(settings.frame_height) 
                                * elements_per_pixel, ))
        
        self.test = np.array([1, 2, 3], dtype=np.uint8)

    def update_frame(self):
        self.frame = self.get_frame()
        self.bgra = cv2.cvtColor(self.frame, cv2.COLOR_BGR2BGRA)

    def window_bgra(self, window_size):
        self.windowed = tricks.window_bgra(
            tricks.pad_array_power_of_2(self.bgra), window_size
        )

    def sort_windowed_bgrabgra(self, window_size, wpr_padded: int, wpc_padded: int):
        tricks.sort_windowed_bgrabgra(
            self.windowed, window_size, wpr_padded, wpc_padded, self.bgrabgra
        )

    def sort_windowed_bbggrraa(self):
        tricks.sort_windowed_bbggrraa(
            self.windowed, self.bbggrraa
        )

    def write_frame(self):
        cv2.imwrite(f"cam {self.index}.png", self.bgra)

    def test_p(self):
        self.test[0] = 9
   