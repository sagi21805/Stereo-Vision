from source.mojo.stereo import *
from source.mojo.camera import *
from source.mojo._utils import *
from time import now
import time


alias first_cam_index = 0
alias second_cam_index = 2
alias window_size = 2

fn main() raises:
    
    var baseLine: Float32 = 60.89  # mm
    var focal_length: Float32 = 2945.377

    var stereo = Stereo[first_cam_index, second_cam_index, window_size, False](
        focal_length, focal_length, baseLine, 
    )

    Python.add_to_path("./source/python")
    var py = Python.import_module("_utils")
    while True:
        stereo.write_frames()
        stereo.generate_disparity_map[is_fake = False]()
        py.write_ptr(
            stereo.depth_map.address.__int__(),
            1,
            (stereo.windows_per_row.__int__(),
            stereo.windows_per_col.__int__())
        )
        time.sleep(0.1)
