from source.mojo.stereo import *
from source.mojo.camera import *
from source.mojo._utils import *
from time import now
import time


fn main() raises:
    var cam1 = Camera(Size[DType.uint32](2864, 1924), 2945.377)
    var cam2 = Camera(Size[DType.uint32](2864, 1924), 2945.377)
    var baseLine: Float32 = 178.232  # mm
    var stereo = Stereo[2](cam1, cam2, baseLine)

    print(cam1.ratio)

    var depth_map = DTypePointer[DType.float32].alloc((stereo.windows_per.row() * stereo.windows_per.col()).__int__())
    var t = now()

    for img_row in range(stereo.windows_per.row()):
        for col in range(stereo.windows_per.col()):
            # var t = now()
            var current_pose = Pose2d[DType.float32](img_row, col)
            var matched_window_pose = stereo.matching_window_position(
                current_pose
            )

            # print("matching calc:", now() - t)
            # t = now()
            var depth: Float32 = stereo.get_depth(
                current_pose, matched_window_pose
            )
        
            # print("depth calc:", now() - t)

            depth_map[img_row * stereo.windows_per.col().__int__() + col] = depth
    
    for i in range(10):
        print(depth_map[i])

    print("took", (now() - t) / 1000000000, "seconds")
    var np = Python.import_module("numpy")
    var ctypes = Python.import_module("ctypes")
    var cv2 = Python.import_module("cv2")
    var ptr = depth_map.address.__int__()
    print(ptr)
    var data_pointer = ctypes.cast(ptr, ctypes.POINTER(ctypes.c_float))
    var numpy_array = np.ctypeslib.as_array(data_pointer, shape=(stereo.windows_per.row().__int__(), stereo.windows_per.col().__int__()))
    cv2.imwrite("test.png", numpy_array)
