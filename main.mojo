from source.mojo.stereo import *
from source.mojo.camera import *
from source.mojo._utils import *
from time import now
import time
from source.mojo.cam_settings import CamSettings
from source.mojo.cam_parameters import CamParameters


alias first_cam_index = 0
alias second_cam_index = 2
alias window_size = 2
        


fn main() raises:

    alias settings =  CamSettings(frame_width = 2864, frame_height = 1924)
    var parameters =  CamParameters(-1, -1, settings)
    alias first_index = 0
    alias second_index = 2
    alias window_size = 8

    # print("here")
    var base_line: Float32 = 60.89  # mm
    # var focal_length: Float32 = 2945.377

    var stereo = Stereo[
        first_cam_index,
        second_cam_index, 
        window_size, 
        settings, 
        fake1 = "data/im1-min.jpeg",
        fake2 = "data/im0-min.jpeg"
        ](base_line, parameters)

    

   
    while True:
        print("in loop")
        stereo.generate_disparity_map()
