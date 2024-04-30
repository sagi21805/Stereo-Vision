from memory import memcpy
from time import now
from math import clamp
import math
from python import Python
from _utils import Size, FOV, Pose2d


struct Camera:
    var cam: PythonObject
    var frame_size: Size[DType.uint16]  # In Pixels
    var focal_length: Float32  # In Pixels
    var fov: FOV[DType.float32]  # In Radians
    var ratio: SIMD[DType.float32, 2]

    fn __init__[
        index: UInt32, frame_size: Size[DType.uint16], focal_length: Float32
    ](inout self) raises:
        Python.add_to_path("../python")
        var python_utils: PythonObject = Python.import_module("_utils")

        self.cam = python_utils.get_camera(index)
        self.frame_size = frame_size
        self.focal_length = focal_length
        self.fov = FOV[DType.float32](
            2
            * math.atan(
                frame_size.size.cast[DType.float32]() / 2 * focal_length
            )
        )
        self.ratio = self.fov.fov / frame_size.size.cast[DType.float32]()

    fn __init__[
        index: UInt32, frame_size: Size[DType.uint16], fov: FOV[DType.float32]
    ](inout self) raises:
        Python.add_to_path("../python")
        var python_utils: PythonObject = Python.import_module("_utils")

        self.cam = python_utils.get_camera(index)
        self.frame_size = frame_size
        self.fov = fov
        self.focal_length = self.frame_size.width().cast[DType.float32]() / (
            2 * math.tan(self.fov.horizontal())
        )
        self.ratio = fov.fov / frame_size.size.cast[DType.float32]()

    fn __init__[
        frame_size: Size[DType.uint16], fov: FOV[DType.float32]
    ](inout self) raises:
        Python.add_to_path("../python")
        var python_utils: PythonObject = Python.import_module("_utils")

        self.cam = PythonObject()
        self.frame_size = frame_size
        self.fov = fov
        self.focal_length = self.frame_size.width().cast[DType.float32]() / (
            2 * math.tan(self.fov.horizontal())
        )
        self.ratio = fov.fov / frame_size.size.cast[DType.float32]()

    fn get_frame(inout self) raises -> DTypePointer[DType.uint8]:
        return _utils.numpy_data_pointer_ui8(self.cam.read()[1])

    fn angle_to_camera(
        inout self, position: Pose2d[DType.float32]
    ) -> FOV[DType.float32]:
        return FOV[DType.float32](self.ratio * position.pose)
