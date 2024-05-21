from python import Python
from source.mojo._utils import *
from source.mojo.camera import Camera
import math
from time import now
import time
from memory import memset_zero


struct Stereo[
    first_camera_index: UInt32,
    second_camera_index: UInt32,
    window_size: Int,
    auto_exposure: Bool = True,
    exposure: Int = 157,
    brightness: Int = 0,
    contrast: Int = 32,
    saturation: Int = 90,
    gain: Int = 0,
    frame_width: Int = 1280,
    frame_height: Int = 720,
    fake1: StringLiteral = "",
    fake2: StringLiteral = "",
]:
    var cam1: Camera[
        first_camera_index,
        auto_exposure,
        exposure,
        brightness,
        contrast,
        saturation,
        gain,
        frame_width,
        frame_height,
        fake1,
    ]

    var cam2: Camera[
        second_camera_index,
        auto_exposure,
        exposure,
        brightness,
        contrast,
        saturation,
        gain,
        frame_width,
        frame_height,
        fake2,
    ]

    var base_line: Float32  # mm

    var frame1_bgrabgra_sum: DTypePointer[DType.uint16]

    var frame2_bbggrraa_sum: DTypePointer[DType.uint16]

    var helper_pointer: DTypePointer[DType.float32]

    var can_match: DTypePointer[DType.bool]
    var depth_map: DTypePointer[DType.float32]
    var python_utils: python_lib

    alias frame_width_padded = closet_power_of_2[frame_width]()
    
    alias frame_height_padded = closet_power_of_2[frame_height]()

    alias windows_per_row: Int = frame_width // window_size

    alias windows_per_col: Int = frame_height // window_size

    alias window_per_row_padded: Int = closet_power_of_2[
        frame_width
    ]() // window_size

    alias window_per_col_padded: Int = closet_power_of_2[
        frame_height
    ]() // window_size

    alias elements_per_pixel: Int = 4  # b, g, r, a

    alias items_to_load = closet_power_of_2[
        frame_width
    ]() * window_size * 4  # can't use self

    fn __init__(
        inout self,
        focal_length1: Float32,
        focal_length2: Float32,
        base_line: Float32,
    ) raises:
        self.cam1 = Camera[
            first_camera_index,
            auto_exposure,
            exposure,
            brightness,
            contrast,
            saturation,
            gain,
            frame_width,
            frame_height,
            fake1,
        ](focal_length1)

        self.cam2 = Camera[
            second_camera_index,
            auto_exposure,
            exposure,
            brightness,
            contrast,
            saturation,
            gain,
            frame_width,
            frame_height,
            fake2,
        ](focal_length2)

        self.base_line = base_line

        self.frame1_bgrabgra_sum = DTypePointer[DType.uint16]().alloc(
            self.window_per_row_padded * self.window_per_col_padded
        )

        self.frame2_bbggrraa_sum = DTypePointer[DType.uint16]().alloc(
            self.window_per_row_padded * self.window_per_col_padded
        )

        self.helper_pointer = DTypePointer[DType.float32]().alloc(
            window_size * window_size
        )

        self.can_match = DTypePointer[DType.bool].alloc(
            (self.windows_per_col * self.windows_per_row).__int__()
        )

        self.depth_map = DTypePointer[DType.float32].alloc(
            (self.windows_per_row * self.windows_per_col).__int__()
        )
        Python.add_to_path("./source/python")
        self.python_utils = Python.import_module("_utils")

        print("init")

    fn update[fake: Bool = False](inout self) raises:
        @parameter  # if statement runs at compile time
        if not fake:
            self.cam1.update_frame()
            self.cam2.update_frame()

            self.cam1.sort_windowed_bgrabgra[window_size]()

            var frame1_bgrabgra_sum = numpy_data_pointer_ui8(
                self.cam1.cap.bgrabgra
            ).load[
                width = (
                    self.frame_width_padded
                    * self.frame_height_padded
                    * self.elements_per_pixel 
                )
            ]().cast[DType.uint16]().reduce_add[
                self.window_per_row_padded
                * self.window_per_col_padded
                * self.elements_per_pixel  
            ]()

            var t = frame1_bgrabgra_sum.slice[4, offset = 0]()
            print(t)
            # print(fram)
            # for i in range(100):
            #     print(t[i], end = " ")
            # print(frame1_bgrabgra_sum.size)
            # self.frame1_bgrabgra_sum.store(0, frame1_bgrabgra_sum)

            self.cam2.sort_windowed_bbggrraa[
                self.window_size,
                self.window_per_row_padded,
                self.window_per_col_padded,
            ]()

            var frame2_bbggrraa_sum = numpy_data_pointer_ui8(
                self.cam2.cap.bbggrraa
            ).load[
                width = (
                    self.frame_width_padded
                    * self.frame_height_padded
                    * self.elements_per_pixel
                )
            ]().cast[DType.uint16]().reduce_add[
                self.window_per_row_padded
                * self.window_per_col_padded
                * self.elements_per_pixel
            ]()

            # self.frame2_bbggrraa_sum.store(0, frame2_bbggrraa_sum)

        # memset_zero(
        #     self.can_match,
        #     (self.windows_per_col * self.windows_per_row).__int__(),
        # )

    # fn get_depth(
    #     inout self,
    #     first_window_pose: Pose2d[DType.float32],
    #     second_window_pose: Pose2d[DType.float32],
    # ) -> Float32:
    #     var angle_from_cam1 = self.cam1.angle_to_camera(first_window_pose)
    #     var angle_from_cam2 = self.cam2.angle_to_camera(second_window_pose)

    #     var angle_A: Float32 = pi_over_2 + (
    #         self.cam1.fov.horizontal() / 2
    #     ) - angle_from_cam1.horizontal()

    #     var angle_B: Float32 = pi_over_2 - (
    #         self.cam2.fov.horizontal() / 2
    #     ) + angle_from_cam2.horizontal()

    #     var angle_C: Float32 = angle_from_cam1.horizontal() - angle_from_cam2.horizontal()

    #     return (self.base_line * math.sin(angle_A) * math.sin(angle_B)) / (
    #         math.sin(angle_C) * math.cos(angle_from_cam1.vertical())
    #     )

    # fn windowMSE(
    #     inout self,
    #     inout first_window_offset: Int32,
    #     inout second_window_offset: Int32,
    # ) -> UInt32:
    #     var first = self.frame1_windowed.load[
    #         width = window_size * window_size
    #     ](first_window_offset)

    #     var second = self.frame2_windowed.load[
    #         width = window_size * window_size
    #     ](second_window_offset)

    #     return math.abs(first - second).cast[DType.uint32]().reduce_add[1]()

    # fn matching_window_position(
    #     inout self, inout matched_window_pose: Pose2d[DType.float32]
    # ) -> Pose2d[DType.float32]:
    #     var matching_col = UInt32.MAX
    #     var error: UInt32 = UInt32.MAX

    #     var row_offset = matched_window_pose.row().cast[
    #         DType.int32
    #     ]() * self.cam1.frame_size.width() * window_size

    #     var matched_window_offset = row_offset + matched_window_pose.col().cast[
    #         DType.int32
    #     ]() * window_size * window_size

    #     for col in range(
    #         0,
    #         self.windows_per_col * window_size * window_size,
    #         window_size * window_size,
    #     ):
    #         var current_window_offset = row_offset + col

    #         var current_error = self.windowMSE(
    #             matched_window_offset, current_window_offset
    #         )
    #         if (
    #             current_error < error
    #             and not self.can_match[current_window_offset]
    #         ):
    #             matching_col = col // (window_size * window_size)
    #             error = current_error

    #         if error < 7:
    #             break

    #     self.can_match[
    #         matched_window_pose.row().cast[DType.uint32]()
    #         * self.windows_per_col
    #         + (matching_col // (window_size * window_size))
    #     ] = True

    #     return Pose2d[DType.float32](
    #         matched_window_pose.row().cast[DType.float32](),
    #         matching_col.cast[DType.float32](),
    #     )

    # always the matched is from frame one and the matching is from frame 2
    # fn match_row(inout self, inout row: Int) raises -> Pose2d[DType.float32]:
    #     var row_bbggrraa_sum = self.frame2_bbggrraa_sum.load[
    #         width = self.items_to_load
    #     ](self.items_to_load * row)

    #     for window_col in range(self.windows_per_row):

    #         var window = self.frame1_bgrabgra_sum.load[
    #             width = self.elements_per_pixel
    #         ](window_col * self.elements_per_pixel)

    #         var window_sum = window.reduce_add()

    #         var coefficient_window = window.cast[DType.float32]() / window_sum.cast[DType.float32]()

    #         var repeated_window = repeat_elements_ui16[
    #             window.size, self.items_to_load // self.elements_per_pixel
    #         ]

    #         var repetead_coefficient_window = repeat_elements_f32[
    #             coefficient_window.size,
    #             self.items_to_load // self.elements_per_pixel,
    #         ](self.helper_pointer, self.python_utils)

    #         # var rgba_error =

    #     return Pose2d[DType.float32](0, 0)

    fn write_frames(inout self) raises:
        self.cam1.write_frame()
        self.cam2.write_frame()

    # fn generate_disparity_map[is_fake: Bool = False](inout self) raises:
    #     var t = now()
    #     self.update[is_fake]()
    #     print("update time: ", (now() - t) / 1000000000)
    #     t = now()
    #     for img_row in range(self.windows_per_col):
    #         for col in range(self.windows_per_row):
    #             var current_pose = Pose2d[DType.float32](img_row, col)
    #             var matched_window_pose = self.matching_window_position(
    #                 current_pose
    #             )

    #             var depth = current_pose.col() - matched_window_pose.col()
    #             self.depth_map[
    #                 img_row * self.windows_per_row.__int__() + col
    #             ] = depth
    #             # var depth: Float32 = stereo.get_depth[pi_over_2](
    #             #     current_pose, matched_window_pose
    #             # )
    #     print("disparity time: ", (now() - t) / 1000000000)
    #     print("")
