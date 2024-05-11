from source.mojo.stereo import *
from source.mojo.camera import *
from source.mojo._utils import *
from time import now
import time


fn main() raises:
    var baseLine: Float32 = 60.89  # mm
    var focal_length: Float32 = 2945.377
    alias first_cam_index = 0
    alias second_cam_index = 2
    alias window_size = 2

    var stereo = Stereo[first_cam_index, second_cam_index, window_size, frame_width = 640, frame_height = 480](
        focal_length, focal_length, baseLine
    )

    Python.add_to_path("./source/python")
    var py = Python.import_module("_utils")
    while True:
        stereo.write_frames()
        var t = now()
        stereo.generate_disparity_map[is_fake= False]()
        print((now() - t) / 1000000000)
        py.write_ptr(
            stereo.depth_map.address.__int__(),
            stereo.windows_per_row.__int__(),
            stereo.windows_per_col.__int__(),
        )
        time.sleep(0.01)
