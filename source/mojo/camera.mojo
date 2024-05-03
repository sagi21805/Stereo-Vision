from memory import memcpy
from time import now
from math import clamp
import math
from python import Python
from source.mojo._utils import *


struct Camera[]:
    var cam: video_capture
    var frame_size: Size[DType.uint32]  # In Pixels
    var focal_length: Float32  # In Pixels
    var fov: FOV[DType.float32]  # In Radians
    var ratio: SIMD[DType.float32, 2]

    fn __init__(
        inout self,
        index: UInt32,
        frame_size: Size[DType.uint32],
        focal_length: Float32,
    ) raises:
        Python.add_to_path("source/python/")
        var python_utils: python_lib = Python.import_module("_utils")

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

    fn __init__(
        inout self,
        index: UInt32,
        frame_size: Size[DType.uint32],
        fov: FOV[DType.float32],
    ) raises:
        Python.add_to_path("source/python/")
        var python_utils: python_lib = Python.import_module("_utils")

        self.cam = python_utils.get_camera(index)
        self.frame_size = frame_size
        self.fov = fov
        self.focal_length = self.frame_size.width().cast[DType.float32]() / (
            2 * math.tan(self.fov.horizontal())
        )
        self.ratio = fov.fov / frame_size.size.cast[DType.float32]()

    fn __init__(
        inout self, frame_size: Size[DType.uint32], focal_length: Float32
    ) raises:
        Python.add_to_path("source/python/")
        var python_utils: PythonObject = Python.import_module("_utils")

        self.cam = video_capture()
        self.frame_size = frame_size
        self.focal_length = focal_length
        self.fov = FOV[DType.float32](
            2
            * math.atan(
                frame_size.size.cast[DType.float32]() / 2 * focal_length
            )
        )
        self.ratio = self.fov.fov / frame_size.size.cast[DType.float32]()

    fn __copyinit__(inout self, cam: Camera):
        self.cam = cam.cam
        self.focal_length = cam.focal_length
        self.fov = cam.fov
        self.frame_size = cam.frame_size
        self.ratio = cam.ratio

    fn get_frame(inout self) raises -> numpy_array:
        return self.cam.read()[1]

    fn angle_to_camera(
        inout self, position: Pose2d[DType.float32]
    ) -> FOV[DType.float32]:
        return FOV[DType.float32](self.ratio * position.pose)
