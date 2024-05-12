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
    colored: Bool, 
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
    var windows_per_row: Int  # how many windows are at the small size of the frame
    var windows_per_col: Int  # how many window are at the big size of the frame

    var frame1_windowed: DTypePointer[DType.uint8]
    var frame2_windowed: DTypePointer[DType.uint8]

    var can_match: DTypePointer[DType.bool]
    var depth_map: DTypePointer[DType.float32]

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

        self.windows_per_col = (
            self.cam1.frame_size.width().__int__() // window_size
        )
        self.windows_per_row = (
            self.cam1.frame_size.height().__int__() // window_size
        )

        self.frame1_windowed = numpy_data_pointer_ui8(
            self.cam1.cap.windowed_frame
        )
        self.frame2_windowed = numpy_data_pointer_ui8(
            self.cam2.cap.windowed_frame
        )

        self.can_match = DTypePointer[DType.bool].alloc(
            (self.windows_per_col * self.windows_per_row).__int__()
        )

        self.depth_map = DTypePointer[DType.float32].alloc(
            (self.windows_per_row * self.windows_per_col).__int__()
        )

    fn update[fake: Bool = False](inout self) raises:
        @parameter  # if statement runs at compile time
        if not fake:
            self.cam1.update_frame()
            self.cam2.update_frame()

            @parameter # if statement runs at compile time
            if self.colored:
                self.cam1.window_colored_frame[self.window_size]()
                self.cam2.window_colored_frame[self.window_size]()
            else:
                self.cam1.window_frame[self.window_size]()
                self.cam2.window_frame[self.window_size]()

            self.frame1_windowed = numpy_data_pointer_ui8(
                self.cam1.cap.windowed_frame
            )
            self.frame2_windowed = numpy_data_pointer_ui8(
                self.cam2.cap.windowed_frame
            )

        memset_zero(
            self.can_match,
            (self.windows_per_col * self.windows_per_row).__int__(),
        )

    fn get_depth(
        inout self,
        first_window_pose: Pose2d[DType.float32],
        second_window_pose: Pose2d[DType.float32],
    ) -> Float32:
        var angle_from_cam1 = self.cam1.angle_to_camera(first_window_pose)
        var angle_from_cam2 = self.cam2.angle_to_camera(second_window_pose)

        var angle_A: Float32 = pi_over_2 + (
            self.cam1.fov.horizontal() / 2
        ) - angle_from_cam1.horizontal()

        var angle_B: Float32 = pi_over_2 - (
            self.cam2.fov.horizontal() / 2
        ) + angle_from_cam2.horizontal()

        var angle_C: Float32 = angle_from_cam1.horizontal() - angle_from_cam2.horizontal()

        return (self.base_line * math.sin(angle_A) * math.sin(angle_B)) / (
            math.sin(angle_C) * math.cos(angle_from_cam1.vertical())
        )

    fn windowMSE(
        inout self,
        inout first_window_offset: Int32,
        inout second_window_offset: Int32,
    ) -> UInt32:
        var first = self.frame1_windowed.load[
            width = window_size * window_size
        ](first_window_offset)

        var second = self.frame2_windowed.load[
            width = window_size * window_size
        ](second_window_offset)

        return math.abs(first - second).cast[DType.uint32]().reduce_add[1]()

    fn matching_window_position(
        inout self, inout matched_window_pose: Pose2d[DType.float32]
    ) -> Pose2d[DType.float32]:
        var matching_col = UInt32.MAX
        var error: UInt32 = UInt32.MAX

        var row_offset = matched_window_pose.row().cast[
            DType.int32
        ]() * self.cam1.frame_size.width() * window_size

        var matched_window_offset = row_offset + matched_window_pose.col().cast[
            DType.int32
        ]() * window_size * window_size

        for col in range(
            0,
            self.windows_per_col * window_size * window_size,
            window_size * window_size,
        ):
            var current_window_offset = row_offset + col

            var current_error = self.windowMSE(
                matched_window_offset, current_window_offset
            )
            if (
                current_error < error
                and not self.can_match[current_window_offset]
            ):
                matching_col = col // (window_size * window_size)
                error = current_error

            if error < 7:
                break

        self.can_match[
            matched_window_pose.row().cast[DType.uint32]()
            * self.windows_per_col
            + (matching_col // (window_size * window_size))
        ] = True

        return Pose2d[DType.float32](
            matched_window_pose.row().cast[DType.float32](),
            matching_col.cast[DType.float32](),
        )

    fn write_frames(inout self) raises:
        self.cam1.write_frame()
        self.cam2.write_frame()

    fn generate_disparity_map[is_fake: Bool = False](inout self) raises:

        var t = now()
        self.update[is_fake]()
        print("update time: ",(now() - t) / 1000000000)
        t = now()
        for img_row in range(self.windows_per_row):
            for col in range(self.windows_per_col):
                var current_pose = Pose2d[DType.float32](img_row, col)
                var matched_window_pose = self.matching_window_position(
                    current_pose
                )

                var depth = current_pose.col() - matched_window_pose.col()
                self.depth_map[
                    img_row * self.windows_per_col.__int__() + col
                ] = depth
                # var depth: Float32 = stereo.get_depth[pi_over_2](
                #     current_pose, matched_window_pose
                # )
        print("disparity time: ",(now() - t) / 1000000000)
        print("")