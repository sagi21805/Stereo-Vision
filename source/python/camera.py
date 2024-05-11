import numpy as np
import cv2 
from time import sleep

class Camera:
    
    def __init__(self, 
                index: int,
                auto_exposure: bool = True,
                exposure: int = 157,
                brightness: int = 0,
                contrast: int = 32,
                saturation: int = 90,
                gain: int = 0,
                frame_width: int = 1280,
                frame_height: int = 720, 
                fake: str = ""
                ):
        
        if fake == "":
            self.cap = Camera.initialize_cap(
                        index, 
                        auto_exposure, 
                        exposure, 
                        brightness, 
                        contrast, 
                        saturation, 
                        gain, 
                        frame_width, 
                        frame_height
                        )
            self.warm()
            
        else:        
            self.cap = cv2.VideoCapture()
            self.frame = cv2.imread(fake)
            
        self.index = index
        self.window_frame(2)
        

    def update_frame(self):
        success, frame = self.cap.read()
        self.frame = frame if success else np.empty(0)
        
    @staticmethod
    def initialize_cap(
                index: int,
                auto_exposure: bool = True,
                exposure: int = 157,
                brightness: int = 0,
                contrast: int = 32,
                saturation: int = 90,
                gain: int = 0,
                frame_width: int = 1280,
                frame_height: int = 720) -> None:
        
        cap = cv2.VideoCapture(index)
        cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter.fourcc(*"MJPG"))
        cap.set(cv2.CAP_PROP_AUTO_EXPOSURE, 3 - (not auto_exposure).__int__()*2)
        cap.set(cv2.CAP_PROP_EXPOSURE, exposure)
        cap.set(cv2.CAP_PROP_BRIGHTNESS, brightness)
        cap.set(cv2.CAP_PROP_CONTRAST, contrast)
        cap.set(cv2.CAP_PROP_SATURATION, saturation)
        cap.set(cv2.CAP_PROP_GAIN, gain)
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, frame_width)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, frame_height)
        
        return cap
        
    def window_frame(self, window_size):
        if self.frame.ndim == 3:
            self.frame = cv2.cvtColor(self.frame, cv2.COLOR_BGR2GRAY)
        
        self.windowed_frame = np.lib.stride_tricks \
              .sliding_window_view(self.frame, (window_size, window_size)) \
              [::window_size, ::window_size].copy()
        
              
    def warm(self):
        for _ in range(10):
            self.update_frame()
              
    def write_frame(self):
        cv2.imwrite(f"camera{self.index}.png", self.frame)
        
    def set_exposure(self, exposure: int):
        self.cap.set(cv2.CAP_PROP_EXPOSURE, exposure)
        
    def set_auto_exposure(self, val: bool):
        self.cap.set(cv2.CAP_PROP_AUTO_EXPOSURE, 3 - (not val).__int__()*2)


        