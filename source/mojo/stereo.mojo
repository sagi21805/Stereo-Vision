from python import Python
from source.mojo._utils import *
from source.mojo.camera import Camera
import math


struct Stereo[window_size: Int]:
    var cam1: Camera
    var cam2: Camera
    var frame1: numpy_array
    var frame2: numpy_array
    var frame1_windowed_view: DTypePointer[DType.uint8]
    var frame2_windowed_view: DTypePointer[DType.uint8]
    var base_line: Float32  # mm
    var windows_per: Pose2d[DType.float32]
    var can_match: List[Bool]
    var depthMap: List[Float32]

    fn __init__(
        inout self,
        cam1: Camera,
        cam2: Camera,
        base_line: Float32,
    ) raises:
        Python.add_to_path("source/python/")
        var python_utils: python_lib = Python.import_module("_utils")
        self.cam1 = cam1
        self.cam2 = cam2
        self.frame1 = python_utils.read_image("data/im1-min.jpeg")
        self.frame2 = python_utils.read_image("data/im0-min.jpeg")
        self.frame1_windowed_view = get_window_view[self.window_size](
            self.frame1, python_utils
        )
        self.frame2_windowed_view = get_window_view[self.window_size](
            self.frame2, python_utils
        )
        self.base_line = base_line
        self.windows_per = Pose2d[DType.float32](
            (self.cam1.frame_size.size / window_size).cast[DType.float32]()
        )
        self.can_match = List[Bool]()
        self.depthMap = List[Float32]()
        var num_of_pixels = self.cam1.frame_size.area()
        self.can_match.reserve(
            (self.windows_per.row() * self.windows_per.col()).__int__()
        )
        self.depthMap.reserve(num_of_pixels)
        for p in range(num_of_pixels):
            self.can_match[p] = True
            self.depthMap[p] = 0.0

    fn get_depth(
        inout self,
        first_window_pose: Pose2d[DType.float32],
        second_window_pose: Pose2d[DType.float32],
    ) -> Float32:
        var pi_over_2: Float32 = 1.57079632679

        var angle_from_cam1 = self.cam1.angle_to_camera(first_window_pose)
        var angle_from_cam2 = self.cam2.angle_to_camera(second_window_pose)

        var angle_A: Float32 = pi_over_2 + (
            self.cam1.fov.horizontal() / 2
        ) - angle_from_cam1.horizontal()

        var angle_B: Float32 = pi_over_2 - (
            self.cam2.fov.horizontal() / 2
        ) - angle_from_cam2.horizontal()

        var angle_C: Float32 = angle_from_cam1.horizontal() - angle_from_cam2.horizontal()

        return (self.base_line * math.sin(angle_A) * math.sin(angle_B)) / (
            math.sin(angle_C) * math.cos(angle_from_cam1.vertical())
        )

    fn windowMSE(
        inout self,
        inout pose1: Pose2d[DType.float32],
        inout pose2: Pose2d[DType.float32],
    ) -> UInt32:
        var first_window = SIMD[DType.uint8, window_size * window_size]()
        var second_window = SIMD[DType.uint8, window_size * window_size]()
        var first_window_number = pose1.row() * self.windows_per.row() + pose1.col()
        var second_window_number = pose2.row() * self.windows_per.row() + pose2.col()
        for window_element in range(window_size * window_size):
            first_window[window_element] = self.frame1_windowed_view[
                first_window_number * window_size * window_size + window_element
            ]
            second_window[window_element] = self.frame2_windowed_view[
                second_window_number * window_size * window_size
                + window_element
            ]

        var error_window = math.abs(first_window - second_window)
        var sum: UInt32 = 0
        for i in range(window_size * window_size):
            sum += error_window[i].cast[DType.uint32]()
        return sum

    fn matching_window_position(
        inout self, inout matched_window_pose: Pose2d[DType.float32]
    ) -> Pose2d[DType.float32]:
        var matching_col = Float32.MAX
        var error = UInt32.MAX
        for col in range(self.windows_per.col()):
            var current_window = Pose2d[DType.float32](
                matched_window_pose.row(), SIMD[DType.float32, 1](col)
            )
            var current_error = self.windowMSE(
                matched_window_pose, current_window
            )
            if (
                current_error < error
                and self.can_match[
                    (
                        matched_window_pose.row() * self.windows_per.row()
                    ).__int__()
                    + col
                ]
            ):
                matching_col = col
                error = current_error

        self.can_match[
            (
                matched_window_pose.row() * self.windows_per.col()
                + matching_col
            ).__int__()
        ] = False
        return Pose2d[DType.float32](matched_window_pose.row(), matching_col)
