import numpy as np
import cv2
from numba import njit, prange
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
        self.elements_per_pixel = 4 # b, g, r, a
        self.window_frame(2)

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

    @njit
    def window_bgra(self, window_size):
        pad_offset_cols = (
            _utils.closet_power_of_2(self.bgra.shape[1]) - self.bgra.shape[1]
        )
        padded = np.pad(
            self.bgra, ((0, 0), (0, pad_offset_cols), (0, 0)), 'constant', constant_values=255
        )
        pad_offset_rows = (
            _utils.closet_power_of_2(self.bgra.shape[0]) - self.bgra.shape[0]
        )
        padded = np.pad(
            padded, ((0, pad_offset_rows), (0, 0), (0, 0)), 'constant', constant_values=255
        )
        self.windowed_frame = np.lib.stride_tricks.sliding_window_view(
            padded, (window_size, window_size, 4)
        )[::window_size, ::window_size].copy()
        self.windowed_frame = self.windowed_frame.reshape(
            (
                self.windowed_frame.shape[0],
                self.windowed_frame.shape[1],
                window_size,
                window_size,
                4,  # bgra
            )
        )
    
    @njit(fastmath=True, parallel=True)
    def sort_windowed_bbrrggaa(
        self, 
        window_size: int,
        windows_per_row: int,
        windows_per_col: int 
        ):
        self.sort_windowed_bgrabgra(window_size)

        self.bbrrggaa = np.empty((self.bgrabgra.size,),dtype=np.uint8,)

        for window_element in prange(window_size*window_size):
            for row in prange(windows_per_col):
                for col in prange(windows_per_row):
                    total_row_elements = windows_per_row * self.elements_per_pixel
                    self.bbrrggaa[col + (row + window_element*windows_per_col) * total_row_elements
                    :((row+1) + window_element*windows_per_col) * total_row_elements
                    :windows_per_row
                    ] = self.bgrabgra[col+(row+window_element*windows_per_col) * windows_per_row]

    @njit(fastmath=True, parallel=True)
    def sort_windowed_bgrabgra(self, window_size):

        self.window_bgra(window_size)

        elements_per_window = 4 # b, g, r, a
    
        self.bgrabgra = np.empty(
            (self.windowed_frame.size // elements_per_window, elements_per_window),
            dtype=np.uint8,
        )

        self.windowed_frame = self.windowed_frame.reshape(
            (
                self.windowed_frame.shape[0] * self.windowed_frame.shape[1],
                window_size * window_size,
                elements_per_window,
            )
        )

        for window in prange(self.windowed_frame.shape[0]):
            self.bgrabgra[window : self.bgrabgra.shape[0] : self.windowed_frame.shape[0]] = self.windowed_frame[window]


    def warm(self):
        for _ in range(10):
            self.update_frame()

    def write_frame(self):
        cv2.imwrite(f"camera{self.index}.png", self.frame)

    def set_exposure(self, exposure: int):
        self.cap.set(cv2.CAP_PROP_EXPOSURE, exposure)

    def set_auto_exposure(self, val: bool):
        self.cap.set(cv2.CAP_PROP_AUTO_EXPOSURE, 3 - (not val).__int__() * 2)
