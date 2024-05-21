import numpy as np
import cv2
import _utils

class Camera:
    def __init__(
        self,
        index: int,
        auto_exposure: bool = True,
        exposure: int = 157,
        brightness: int = 0,
        contrast: int = 32,
        saturation: int = 90,
        gain: int = 0,
        frame_width: int = 1280,
        frame_height: int = 720,
        fake: str = "",
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
                frame_height,
            )
            self.warm()

        else:
            self.cap = cv2.VideoCapture()
            self.frame = cv2.imread(fake)
            self.bgra = cv2.cvtColor(self.frame, cv2.COLOR_BGR2BGRA)

        self.index = index
        self.elements_per_pixel = 4  # b, g, r, a

    def update_frame(self):
        success, frame = self.cap.read()
        self.frame = frame if success else np.empty(0)
        self.bgra = cv2.cvtColor(self.frame, cv2.COLOR_BGR2BGRA)

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
        frame_height: int = 720,
    ) -> None:
        cap = cv2.VideoCapture(index)
        cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter.fourcc(*"MJPG"))
        cap.set(
            cv2.CAP_PROP_AUTO_EXPOSURE, 3 - (not auto_exposure).__int__() * 2
        )
        cap.set(cv2.CAP_PROP_EXPOSURE, exposure)
        cap.set(cv2.CAP_PROP_BRIGHTNESS, brightness)
        cap.set(cv2.CAP_PROP_CONTRAST, contrast)
        cap.set(cv2.CAP_PROP_SATURATION, saturation)
        cap.set(cv2.CAP_PROP_GAIN, gain)
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, frame_width)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, frame_height)

        return cap

    def window_bgra(self, window_size):
        self.windowed_frame = _utils.window_bgra(_utils.pad_array(self.bgra), window_size)

    # @njit(fastmath=True, parallel=True)
    def sort_windowed_bbggrraa(
        self, 
        window_size: int, 
        windows_per_row: int, 
        windows_per_col: int
    ):
        self.sort_windowed_bgrabgra(window_size)
        self.bbggrraa = _utils.sort_windowed_bbggrraa(self.bgrabgra, window_size, windows_per_row, windows_per_col)
        

    def sort_windowed_bgrabgra(self, window_size):
        self.window_bgra(window_size)
        self.bgrabgra = _utils.sort_windowed_bgrabgra(self.windowed_frame, window_size)

   
    def warm(self):
        for _ in range(10):
            self.update_frame()

    def write_frame(self):
        cv2.imwrite(f"camera{self.index}.png", self.frame)

    def set_exposure(self, exposure: int):
        self.cap.set(cv2.CAP_PROP_EXPOSURE, exposure)

    def set_auto_exposure(self, val: bool):
        self.cap.set(cv2.CAP_PROP_AUTO_EXPOSURE, 3 - (not val).__int__() * 2)
