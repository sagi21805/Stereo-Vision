from python import Python
from source.mojo._utils import *
from source.mojo.stereo_cam import StereoCam
from source.mojo.cam_settings import CamSettings
import math
from time import now
import time
from source.mojo.cam_parameters import CamParameters
from memory import memset_zero


struct Stereo[
    first_camera_index: UInt32,
    second_camera_index: UInt32,
    window_size: Int,
    cam_settings: CamSettings,
    elements_per_pixel: Int = 4,
]:
    var cam1: StereoCam[
        first_camera_index, cam_settings, elements_per_pixel
    ]

    var cam2: StereoCam[
        second_camera_index, cam_settings, elements_per_pixel
    ]
    var base_line: Float32  # mm

    var helper: DTypePointer[DType.float32]
    var repeated: DTypePointer[DType.float32]
    var coefficients: DTypePointer[DType.float32]
    var can_match: DTypePointer[DType.bool]
    var disparity_map: DTypePointer[DType.float32]
    var python_utils: python_lib
    
    alias frame_width_padded = closet_power_of_2[cam_settings.frame_width]()

    alias frame_height_padded = closet_power_of_2[cam_settings.frame_height]()

    alias windows_per_row: Int = cam_settings.frame_width // window_size

    alias windows_per_col: Int = cam_settings.frame_height // window_size

    alias window_per_row_padded: Int = closet_power_of_2[
        cam_settings.frame_width
    ]() // window_size

    alias window_per_col_padded: Int = closet_power_of_2[
        cam_settings.frame_height
    ]() // window_size

    alias row_size = closet_power_of_2[
        cam_settings.frame_width
    ]() * window_size * elements_per_pixel

    fn __init__(
        inout self, base_line: Float32, parameters: CamParameters
    ) raises:

        print("frame_width:", cam_settings.frame_width)

        print("frame_height:", cam_settings.frame_height)

        print("frame_width_padded:", self.frame_width_padded)

        print("frame_height_padded:", self.frame_height_padded)

        print("windows_per_row:", self.windows_per_row)

        print("windows_per_col:", self.windows_per_col)

        print("window_per_row_padded:", self.window_per_row_padded)

        print("window_per_col_padded:", self.window_per_col_padded)

        print("row_size:", self.row_size)

        Python.add_to_path("source/python")
        self.python_utils = Python.import_module("_utils")

        self.cam1 = StereoCam[
            first_camera_index, cam_settings, elements_per_pixel
        ](parameters)

        self.cam2 = StereoCam[
            second_camera_index, cam_settings, elements_per_pixel
        ](parameters)

        self.base_line = base_line

        self.coefficients = DTypePointer[DType.float32].alloc(
            (self.window_per_row_padded * elements_per_pixel).__int__()
        )

        self.helper = DTypePointer[DType.float32].alloc(
            (self.window_per_row_padded * elements_per_pixel).__int__()
        )

        self.repeated = DTypePointer[DType.float32].alloc(
            (self.window_per_row_padded 
            * elements_per_pixel 
            * self.window_per_row_padded).__int__()
        )

        self.can_match = DTypePointer[DType.bool].alloc(
            (self.windows_per_col * self.windows_per_row).__int__()
        )

        self.disparity_map = DTypePointer[DType.float32].alloc(
            (self.windows_per_row * self.windows_per_col).__int__()
        )


    fn __del__(owned self: Self):
        self.disparity_map.free()
        self.can_match.free()
        self.repeated.free()
        self.helper.free()
        self.coefficients.free()

    fn update[fake: Bool = False](inout self) raises:
        @parameter  # if statement runs at compile time
        if not fake:
            self.cam1.update_frame()
            self.cam2.update_frame()

            self.cam1.window_bgra(window_size)
            self.cam2.window_bgra(window_size)

            self.cam1.sort_windowed_bgrabgra(
                window_size, self.window_per_row_padded, self.window_per_col_padded
            )

            self.cam2.sort_windowed_bbggrraa()

        memset_zero(
            self.can_match,
            (self.windows_per_col * self.windows_per_row).__int__(),
        )

    fn bug_function(inout self, inout row: Int):
        
        var row_data = self.cam1.bgrabgra.load[width = self.row_size](
            self.row_size * row
        )
        
        var row_matched_windows = row_data.cast[DType.float32]().reduce_add[self.window_per_row_padded * elements_per_pixel]()

        print(row_matched_windows)
        # self.helper.store(row_matched_windows)

    