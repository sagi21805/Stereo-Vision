from memory import memcpy
from time import now
from math import clamp
import math
from python import Python
from _utils import Size, FOV, Pose2d

struct Camera:
    var cam: PythonObject
    var frame_size: Size[DType.uint16] # In Pixels
    var focal_length: Float32 # In Pixels
    var fov: FOV[DType.float32] # In Radians
    var frame: DTypePointer[DType.uint8]
    var angle_to_pixle_H: Float32
    var angle_to_pixel_V: Float32
    
    fn __init__[index: UInt32, frame_size: Size[DType.uint16], focal_length: Float32,](inout self) raises:
        Python.add_to_path("../python")
        var py: PythonObject = Python.import_module("_utils")
        
        self.cam = py.get_camera(index)
        self.frame_size = frame_size
        self.focal_length = focal_length
        self.fov = FOV[DType.float32](2*math.atan(frame_size.size.cast[DType.float32]() / 2*focal_length))
        self.frame = _utils.numpy_data_pointer_ui8(self.cam.read()[1])
        var ratio: SIMD[DType.float32, 2] = self.fov.fov / frame_size.size.cast[DType.float32]()
        self.angle_to_pixel_V = ratio[0]
        self.angle_to_pixle_H = ratio[1]

    fn __init__[index: UInt32, frame_size: Size[DType.uint16], fov: FOV[DType.float32]](inout self) raises:
        Python.add_to_path("../python")
        var py: PythonObject = Python.import_module("_utils")
        
        self.cam = py.get_camera(index)
        self.frame_size = frame_size
        self.fov = fov
        self.focal_length = self.frame_size.width().cast[DType.float32]() / (2*math.tan(self.fov.horizontal()))
        self.frame = _utils.numpy_data_pointer_ui8(self.cam.read()[1])
        var ratio: SIMD[DType.float32, 2] = fov.fov / frame_size.size.cast[DType.float32]()
        self.angle_to_pixel_V = ratio[0]
        self.angle_to_pixle_H = ratio[1]

    fn get_frame(inout self) raises -> DTypePointer[DType.uint8]:
        return _utils.numpy_data_pointer_ui8(self.cam.read()[1])

    
        
