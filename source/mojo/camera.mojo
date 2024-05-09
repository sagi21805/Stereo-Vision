import math
from python import Python
from source.mojo._utils import *

@value
struct Camera[
    auto_exposure: Bool = True,
    exposure: Int = 157,
    brightness: Int = 0,
    contrast: Int = 32,
    saturation: Int = 90,
    gain: Int = 0,
    frame_width: Int = 1280,
    frame_height: Int = 720
]:
    var cap: video_capture
    var frame_size: Size[DType.int32]  # In Pixels
    var colored: Bool
    var focal_length: Float32  # In Pixels
    var fov: FOV[DType.float32]  # In Radians
    var ratio: SIMD[DType.float32, 2]

    var cv2: python_lib

    fn __init__(
        inout self,
        index: UInt32,
        focal_length: Float32,
    ) raises:

        Python.add_to_path("source/python")
        self.cv2 = Python.import_module("cv2")
        var python_utils = Python.import_module("_utils")
        self.cap = python_utils.get_camera(index) # get the camera

        self.cap.set(self.cv2.CAP_PROP_AUTO_EXPOSURE, 3 - (not auto_exposure).__int__()*2)
        self.cap.set(self.cv2.CAP_PROP_EXPOSURE, self.exposure)
        self.cap.set(self.cv2.CAP_PROP_BRIGHTNESS, self.brightness)
        self.cap.set(self.cv2.CAP_PROP_CONTRAST, self.contrast)
        self.cap.set(self.cv2.CAP_PROP_SATURATION, self.saturation)
        self.cap.set(self.cv2.CAP_PROP_GAIN, self.gain)
        self.cap.set(self.cv2.CAP_PROP_FRAME_WIDTH, self.frame_width)
        self.cap.set(self.cv2.CAP_PROP_FRAME_HEIGHT, self.frame_height)


        var frame = self.cap.read()[1] if self.cap.read()[0] else numpy_array() 
        self.frame_size = Size[DType.int32](
            frame.shape[1].__int__(), frame.shape[0].__int__()
        )  # width, height

        self.colored = True if frame.ndim == 3 else False 

        self.focal_length = focal_length

        self.fov = FOV[DType.float32](
            2
            * math.atan(
                self.frame_size.size.cast[DType.float32]() / 2 * focal_length
            )
        ) # calculate fov from focal length and frame size

        self.ratio = self.fov.fov / self.frame_size.size.cast[DType.float32]()
        # calc the ratio between pixels and angles
        
        self.warm() # warm the camera

    fn __init__(
        inout self,
        index: UInt32,
        fov: FOV[DType.float32],
    ) raises:

        Python.add_to_path("source/python")
        self.cv2 = Python.import_module("cv2")
        var python_utils = Python.import_module("_utils")
        
        self.cap = python_utils.get_camera(index) # get the camera

        self.cap.set(self.cv2.CAP_PROP_AUTO_EXPOSURE, 3 - (not auto_exposure).__int__()*2)
        self.cap.set(self.cv2.CAP_PROP_EXPOSURE, self.exposure)
        self.cap.set(self.cv2.CAP_PROP_BRIGHTNESS, self.brightness)
        self.cap.set(self.cv2.CAP_PROP_CONTRAST, self.contrast)
        self.cap.set(self.cv2.CAP_PROP_SATURATION, self.saturation)
        self.cap.set(self.cv2.CAP_PROP_GAIN, self.gain)
        self.cap.set(self.cv2.CAP_PROP_FRAME_WIDTH, self.frame_width)
        self.cap.set(self.cv2.CAP_PROP_FRAME_HEIGHT, self.frame_height)

        var frame = self.cap.read()[1] if self.cap.read()[0] else numpy_array() 
        self.frame_size = Size[DType.int32](
            frame.shape[1].__int__(), frame.shape[0].__int__()
        )  # width, height

        self.colored = True if frame.ndim == 3 else False 

        self.fov = fov

        self.focal_length = self.frame_size.width().cast[DType.float32]() / (
            2 * math.tan(self.fov.horizontal())
        )  # calculate focal length from fov and frame size

        self.ratio = fov.fov / self.frame_size.size.cast[DType.float32]()
        # calc the ratio between pixels and angles

        self.warm()  # warm the camera

    fn get_frame(inout self) raises -> numpy_array:
        if self.cap.isOpened():
            return self.cap.read()[1]  # frame
        else:
            return numpy_array()  # None type

    fn warm(inout self) raises:
        for _ in range(10):
            _ = self.get_frame()

    fn angle_to_camera(
        inout self, position: Pose2d[DType.float32]
    ) -> FOV[DType.float32]:
        return FOV[DType.float32](self.ratio * position.pose)

    fn __del__(owned self):
        try:
            self.cap.release()
        except:
            pass
