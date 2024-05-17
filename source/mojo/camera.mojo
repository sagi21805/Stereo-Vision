import math
from python import Python
from source.mojo._utils import *

alias PythonCam = PythonObject


@value
struct Camera[
    index: UInt32,
    auto_exposure: Bool = True,
    exposure: Int = 157,
    brightness: Int = 0,
    contrast: Int = 32,
    saturation: Int = 90,
    gain: Int = 0,
    frame_width: Int = 1280,
    frame_height: Int = 720,
    fake: StringLiteral = "",
]:
    var cap: PythonCam
    var focal_length: Float32  # In Pixels
    var fov: FOV[DType.float32]  # In Radians
    var ratio: SIMD[DType.float32, 2]
    var frame_size: Size[DType.int32]

    fn __init__(inout self, focal_length: Float32) raises:
        Python.add_to_path("source/python")
        var Camera = Python.import_module("camera")
        self.cap = Camera.Camera(
            index,
            auto_exposure,
            exposure,
            brightness,
            contrast,
            saturation,
            gain,
            frame_width,
            frame_height,
            fake,
        )

        self.focal_length = focal_length

        self.frame_size = Size[DType.int32](
            self.cap.frame.shape[1].__int__(), self.cap.frame.shape[0].__int__()
        )

        self.fov = FOV[DType.float32](
            2
            * math.atan(
                self.frame_size.size.cast[DType.float32]()
                / (2 * self.focal_length)
            )
        )
        print(self.fov.fov)
        self.ratio = self.fov.fov / self.frame_size.size.cast[DType.float32]()

    fn angle_to_camera(
        inout self, position: Pose2d[DType.float32]
    ) -> FOV[DType.float32]:
        return FOV[DType.float32](self.ratio * position.pose)

    fn window_gray[window_size: Int](inout self) raises:
        self.cap.window_gray(window_size)

    fn window_bgra[window_size: Int](inout self) raises:
        self.cap.window_bgra(window_size)

    fn special_window_bgra[window_size: Int](inout self) raises:
        self.cap.window_bgra(window_size)
        self.cap.specical_window_bgra()

    fn write_frame(inout self) raises:
        self.cap.write_frame()

    fn update_frame(inout self) raises:
        self.cap.update_frame()

    fn set_exposure(inout self, val: Int) raises:
        self.cap.set_exposure(val)

    fn __del__(owned self):
        try:
            self.cap.cap.release()
        except:
            pass
