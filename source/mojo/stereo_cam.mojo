from python import Python
from source.mojo.cam_settings import CamSettings
from source.mojo.cam_parameters import CamParameters
from source.mojo._utils import Pose2d, FOV, numpy_data_pointer_ui8
alias PyStereoCam = PythonObject


@value
struct StereoCam[
    index: UInt32,
    settings: CamSettings,
    elements_per_pixel: Int = 4, # b, g, r, a
    fake: StringLiteral = ""
]:

    var cap: PyStereoCam
    var bgrabgra: DTypePointer[DType.uint8]
    var bbggrraa: DTypePointer[DType.uint8]
    var parameters: CamParameters

    fn __init__(inout self, parameters: CamParameters) raises:
        Python.add_to_path("source/python")
        var stereo_cam_module = Python.import_module("stereo_cam") 
        var settings_module = Python.import_module("cam_settings")

        self.parameters = parameters
        
        self.cap = stereo_cam_module.StereoCam(
            index, CamSettings.to_python(settings, settings_module), elements_per_pixel, fake
        )

        self.bgrabgra = numpy_data_pointer_ui8(self.cap.bgrabgra)
        self.bbggrraa = numpy_data_pointer_ui8(self.cap.bbggrraa)


    fn angle_to_camera(
        inout self, position: Pose2d[DType.float32]
    ) -> FOV[DType.float32]:
        return FOV[DType.float32](self.parameters.angle_pixel_ratio.fov * position.pose)


    fn window_bgra(inout self, window_size: Int) raises:
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

    fn write_frame(inout self) raises:
        self.cap.write_frame()

    fn __del__(owned self):
        try:
            self.cap.cap.release()
        except:
            pass
