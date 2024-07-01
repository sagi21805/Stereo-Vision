import cv2


class CamSettings:

    def __init__(self,
                 frame_width: int = 1280,
                 frame_height: int = 800,
                 auto_exposure: bool = True,
                 exposure: int = 157,
                 brightness: int = 0,
                 contrast: int = 32,
                 saturation: int = 90,
                 gain: int = 0,
                 ) -> None:

        self.frame_width = frame_width
        self.frame_height = frame_height
        self.auto_exposure = auto_exposure
        self.exposure = exposure
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        self.gain = gain

    def initialize_cap(self, index) -> None:
        cap = cv2.VideoCapture(index)
        cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter.fourcc(*"MJPG"))
        cap.set(
            cv2.CAP_PROP_AUTO_EXPOSURE, 3 -
            (not self.auto_exposure).__int__() * 2
        )
        cap.set(cv2.CAP_PROP_EXPOSURE, self.exposure)
        cap.set(cv2.CAP_PROP_BRIGHTNESS, self.brightness)
        cap.set(cv2.CAP_PROP_CONTRAST, self.contrast)
        cap.set(cv2.CAP_PROP_SATURATION, self.saturation)
        cap.set(cv2.CAP_PROP_GAIN, self.gain)
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, self.frame_width)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, self.frame_height)

        return cap
