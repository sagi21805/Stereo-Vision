import math
from python import Python
from source.mojo._utils import *
from source.mojo.cam_settings import *
from source.mojo.cam_parameters import *

alias PyStereoCam = PythonObject


@value
struct StereoCam[
    index: UInt32,
    settings: CamSettings,
    parameters: CamParameters,
    window_size: Int,
    elements_per_pixel: Int = 4 # b, g, r, a
]:

    var cap: PyStereoCam
    var focal_length: Float32  # In Pixels
    var fov: FOV[DType.float32]  
    var ratio: SIMD[DType.float32, 2]
    var frame_size: Size[DType.int32]

    fn __init__(inout self, focal_length: Float32) raises:
        Python.add_to_path("source/python")
        var stereo_cam_module = Python.import_module("stereo_cam") 
        var settings_module = Python.import_module("cam_settings")
        
        self.cap = stereo_cam_module.StereoCam(
            index, CamSettings.to_python(settings, settings_module)
        )

        self.focal_length = focal_length

        self.frame_size = Size[DType.int32](
            self.cap.frame.shape[1].__int__(), self.cap.frame.shape[0].__int__()
        )

        self.fov = FOV[DType.float32](
            2
            * math.atan(
                self.frame_size.size.cast[DType.float32]()
                / (2 * self.focal_length)
            )
        )
        print(self.fov.fov)
        self.ratio = self.fov.fov / self.frame_size.size.cast[DType.float32]()

    fn angle_to_camera(
        inout self, position: Pose2d[DType.float32]
    ) -> FOV[DType.float32]:
        return FOV[DType.float32](self.ratio * position.pose)


    fn window_bgra[window_size: Int](inout self) raises:
        self.cap.window_bgra(window_size)

    fn sort_windowed_bgrabgra(
        inout self, window_size: Int, wpr_padded: Int, wpc_padded: Int) raises:
        self.cap.sort_windowed_bgrabgra(window_size, wpr_padded, wpc_padded)

    fn sort_windowed_bbggrraa(inout self) raises:
        self.cap.sort_windowed_bbggrraa()

    fn update_frame(inout self) raises:
        self.cap.update_frame()

    fn set_exposure(inout self, val: Int) raises:
        self.cap.set_exposure(val)

    fn __del__(owned self):
        try:
            self.cap.cap.release()
        except:
            pass
