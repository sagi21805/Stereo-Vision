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
    fake1: StringLiteral = "",
    fake2: StringLiteral = ""
]:
    var cam1: StereoCam[first_camera_index, cam_settings, elements_per_pixel, fake1]

    var cam2: StereoCam[second_camera_index, cam_settings, elements_per_pixel, fake2]
    var base_line: Float32  # mm

    var helper: DTypePointer[DType.float16]
    var repeated: DTypePointer[DType.float16]
    var coefficients: DTypePointer[DType.float16]
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

        print("window_size:", window_size)

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
            first_camera_index, cam_settings, elements_per_pixel, fake1
        ](parameters)

        self.cam2 = StereoCam[
            second_camera_index, cam_settings, elements_per_pixel, fake2
        ](parameters)

        self.base_line = base_line

        self.coefficients = DTypePointer[DType.float16].alloc(
            (self.window_per_row_padded * elements_per_pixel).__int__()
        )

        self.helper = DTypePointer[DType.float16].alloc(
            (self.window_per_row_padded * elements_per_pixel).__int__()
        )

        self.repeated = DTypePointer[DType.float16].alloc(
            (
                self.window_per_row_padded
                * elements_per_pixel
                * self.window_per_row_padded
            ).__int__()
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
                window_size,
                self.window_per_row_padded,
                self.window_per_col_padded,
            )

            self.cam2.sort_windowed_bbggrraa()

        memset_zero(
            self.can_match,
            (self.windows_per_col * self.windows_per_row).__int__(),
        )

    #TODO currently using float16 - max window size is 16, make the float type change depends on window size
    fn row_disparity(inout self, inout row: Int):

        var row_data = self.cam1.bgrabgra.load[width = self.row_size](
            self.row_size * row
        ).cast[DType.float16]().reduce_add[
            self.window_per_row_padded * elements_per_pixel
        ]()

        self.helper.store(row_data)

        _utils.repeat_elements[  # repeated bgrabgra's
            self.window_per_row_padded * elements_per_pixel,
            self.window_per_row_padded,
        ](self.helper, self.repeated)

        var summed_bbggrraa = self.cam2.bbggrraa.load[width = self.row_size](
            self.row_size * row
        ).cast[DType.float16]().reduce_add[
            self.window_per_row_padded * elements_per_pixel
        ]()

        for window_index in range(self.windows_per_row):
            var repeated_window = self.repeated.load[
                width = self.window_per_row_padded * elements_per_pixel
            ](window_index * self.window_per_row_padded * elements_per_pixel)

            var B = repeated_window[self.window_per_row_padded * 0]
            var G = repeated_window[self.window_per_row_padded * 1]
            var R = repeated_window[self.window_per_row_padded * 2]

            var B_coefficient = B / (B + G + R)
            var G_coefficient = G / (B + G + R)
            var R_coefficient = R / (B + G + R)
            var A_coefficient = 1

            var coefficient_simd = SIMD[DType.float16](
                B_coefficient, G_coefficient, R_coefficient, A_coefficient
            )

            self.helper.store(coefficient_simd)

            _utils.repeat_elements[
                input_size=elements_per_pixel,
                times = self.window_per_row_padded,
            ](self.helper, self.coefficients)

            var error_window = repeated_window - summed_bbggrraa

            error_window *= self.coefficients.load[
                width = self.window_per_row_padded * elements_per_pixel
            ]()

            var summed_errors = math.abs(error_window).reduce_add[
                self.window_per_row_padded
            ]()

            # TODO put in a different function

            var min_error = Float16.MAX
            var index = 0

            for error_index in range(self.windows_per_row):
                var current_error = summed_errors[error_index]

                if current_error < min_error:
                    min_error = current_error
                    index = error_index

                if min_error < 3:
                    break

            self.disparity_map[window_index + row * self.windows_per_row] = (
                index - window_index
            )

    fn write_frames(inout self) raises:
        self.cam1.write_frame()
        self.cam2.write_frame()

        self.python_utils.write_ptr(
            self.disparity_map.address.__int__(),
            FLOAT32_C,
            (self.windows_per_col, self.windows_per_row),
        )

    fn generate_disparity_map[is_fake: Bool = False](inout self) raises:
        var t = now()
        self.update[is_fake]()
        print("update time: ", (now() - t) / 1000000000)
        t = now()
        for img_row in range(self.windows_per_col):
            self.row_disparity(img_row)
        print("disparity time: ", (now() - t) / 1000000000)
        self.write_frames()
