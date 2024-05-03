from source.mojo.stereo import *
from source.mojo.camera import *
from source.mojo._utils import *
from time import now

fn main() raises:
    var cam1 = Camera(Size[DType.uint32](2864, 1924), 2945.377)
    var cam2 = Camera(Size[DType.uint32](2864, 1924), 2945.377)
    var baseLine: Float32 = 100.1 #mm
    var stereo = Stereo[2](cam1, cam2, baseLine)

    var t = now()

    for img_row in range(stereo.windows_per.row()):

        for col in range(stereo.windows_per.col()):

            var current_pose = Pose2d[DType.float32](img_row, col)
            var matched_window_pose = stereo.matching_window_position(current_pose)
            var depth: Float32 = stereo.get_depth(current_pose, matched_window_pose)
            stereo.depthMap[img_row * stereo.windows_per.col().__int__() + col] = depth

    print("took", now() - t, "nanoseconds")
    
