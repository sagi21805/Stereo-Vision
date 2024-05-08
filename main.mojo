from source.mojo.stereo import *
from source.mojo.camera import *
from source.mojo._utils import *
from time import now
import time


fn main() raises:
    var cam1 = Camera(2, Size[DType.uint32](1280, 720), 1758.38)
    var cam2 = Camera(0, Size[DType.uint32](1280, 720), 1758.38)
    # var cam1 = Camera(Size[DType.uint32](2864, 1924), 2945.377)
    # var cam2 = Camera(Size[DType.uint32](2864, 1924), 2945.377)
    var baseLine: Float32 = 60.89  # mm
    var stereo = Stereo[2](cam1, cam2, baseLine)
   
   
    while True:
        stereo.generate_disparity_map()
        stereo.cv2.imwrite("1.png", stereo.frame1)
        stereo.cv2.imwrite("2.png", stereo.frame2)
        stereo.cv2.imwrite("3.png", stereo.depth_map_array)
        time.sleep(0.5)
        print("iter")
