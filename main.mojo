from source.mojo.stereo import *
from source.mojo.camera import *
from source.mojo._utils import *
from time import now
import time


fn main() raises:
    var t = now()
    var cam1 = Camera(Size[DType.uint32](2864, 1924), 2945.377)
    var cam2 = Camera(Size[DType.uint32](2864, 1924), 2945.377)
    var baseLine: Float32 = 178.232  # mm
    var stereo = Stereo[4](cam1, cam2, baseLine)
    alias pi_over_2 = 1.57079632679489661923
    var depth_map = DTypePointer[DType.float32].alloc((stereo.windows_per_row * stereo.windows_per_col).__int__())
    
    print("per row:", stereo.windows_per_row, "per col:", stereo.windows_per_col)

    for img_row in range(stereo.windows_per_row):
        
        for col in range(stereo.windows_per_col):
            var current_pose = Pose2d[DType.float32](img_row, col)
            var matched_window_pose = stereo.matching_window_position(
                current_pose
            )

        
            var depth: Float32 = stereo.get_depth[pi_over_2](
                current_pose, matched_window_pose
            )


            depth_map[img_row * stereo.windows_per_col.__int__() + col] = depth
    

    print("took", (now() - t) / 1000000000, "seconds")
    var np = Python.import_module("numpy")
    var ctypes = Python.import_module("ctypes")
    var cv2 = Python.import_module("cv2")
    var ptr = depth_map.address.__int__()
    var data_pointer = ctypes.cast(ptr, ctypes.POINTER(ctypes.c_float))
    var numpy_array = np.ctypeslib.as_array(data_pointer, shape=(stereo.windows_per_row.__int__(), stereo.windows_per_col.__int__()))
    cv2.imwrite("test.png", numpy_array)
