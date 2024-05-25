from python import Python
from source.mojo._utils import *

@value
struct CamSettings:

    var auto_exposure: Bool
    var exposure: Int
    var brightness: Int
    var contrast: Int
    var saturation: Int
    var gain: Int
    var frame_width: Int
    var frame_height: Int
    var fake: StringLiteral

    fn __init__(
        inout self,
        auto_exposure: Bool = True,
        exposure: Int = 157,
        brightness: Int = 0,
        contrast: Int = 32,
        saturation: Int = 90,
        gain: Int = 0,
        frame_width: Int = 1280,
        frame_height: Int = 720,
        fake: StringLiteral = ""
    ):

        self.auto_exposure = auto_exposure  
        self.exposure = exposure
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        self.gain = gain
        self.frame_width = frame_width 
        self.frame_height = frame_height
        self.fake = fake

    fn to_python(inout self, camera_settings_module: python_lib) raises -> PythonObject:
        return camera_settings_module.CamSettings(
            self.frame_width,
            self.frame_height,
            self.auto_exposure,
            self.exposure,
            self.brightness,
            self.contrast,
            self.saturation,
            self.gain,
            self.fake
        )
    
    @staticmethod
    fn to_python(settings: Self, camera_settings_module: python_lib) raises -> PythonObject:
        return camera_settings_module.CamSettings(
            settings.frame_width,
            settings.frame_height,
            settings.auto_exposure,
            settings.exposure,
            settings.brightness,
            settings.contrast,
            settings.saturation,
            settings.gain,
            settings.fake
        )


