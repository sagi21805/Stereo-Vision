from python import Python
from source.mojo._utils import *
from source.mojo.camera import Camera
import math
from time import now
from memory import memset_zero


struct Stereo[window_size: Int, elements_per_window:Int = window_size*window_size
             ,first_window: Int = 0, second_window: Int = 1]:
    var cam1: Camera
    var cam2: Camera
    var frame1: numpy_array
    var frame2: numpy_array
    var frame1_windowed_view: DTypePointer[DType.uint8]
    var frame2_windowed_view: DTypePointer[DType.uint8]
    var base_line: Float32  # mm
    var windows_per_row: Int # how many windows are at the small size of the frame
    var windows_per_col: Int # how many window are at the big size of the frame
    var can_match: DTypePointer[DType.bool]
    var count: Int

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
        self.frame1 = python_utils.read_image("data/im0-min.jpeg")
        self.frame2 = python_utils.read_image("data/im1-min.jpeg")
    
        print(self.frame1.shape)

        self.frame1_windowed_view = get_window_view[
            self.window_size, self.first_window
        ](self.frame1, python_utils)
        self.frame2_windowed_view = get_window_view[
            self.window_size, self.second_window
        ](self.frame2, python_utils)
        self.base_line = base_line
        
        self.windows_per_col = self.cam1.frame_size.width().__int__() // window_size
        self.windows_per_row = self.cam1.frame_size.height().__int__() // window_size

        self.can_match = DTypePointer[DType.bool].alloc(
            (self.windows_per_col * self.windows_per_row).__int__()
        )
        memset_zero(
            self.can_match,
            (self.windows_per_col * self.windows_per_row).__int__(),
        )
        self.count = 0

    fn get_depth[pi_over_2: Float32](
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
            math.sin(angle_C) * math.cos(angle_from_cam1.vertical()))

    fn windowMSE(
        inout self,
        inout first_window_offset: UInt32,
        inout second_window_offset: UInt32,
    ) -> UInt32:

        var first = self.frame1_windowed_view.load[
            width = elements_per_window
        ](first_window_offset)
        
        var second = self.frame2_windowed_view.load[
            width = elements_per_window
        ](second_window_offset)

        return math.abs(first - second).cast[DType.uint32]().reduce_add[1]()
        
        

    fn matching_window_position(
        inout self, inout matched_window_pose: Pose2d[DType.float32]
    ) -> Pose2d[DType.float32]:
        var matching_col = UInt32.MAX
        var error: UInt32 = UInt32.MAX

        var row_offset = matched_window_pose.row().cast[
            DType.uint32
        ]() * self.cam1.frame_size.width() * window_size

        var matched_window_offset = row_offset + matched_window_pose.col().cast[
            DType.uint32]() * elements_per_window

        for col in range(
            0,
            self.windows_per_col * elements_per_window,
            elements_per_window,
        ):
            # print(self.windows_per.col())

            var current_window_offset = row_offset + col

            var current_error = self.windowMSE(
                matched_window_offset, current_window_offset
            )
            if (
                current_error < error
                and not self.can_match[current_window_offset]
            ):
                matching_col = col // elements_per_window
                error = current_error

            # if error == 0:
            #     break
                # print(matching_col)

        self.can_match[
            matched_window_pose.row().cast[DType.uint32]()
            * self.windows_per_col
            + (matching_col // elements_per_window)
        ] = True

        return Pose2d[DType.float32](
            matched_window_pose.row().cast[DType.float32](),
            matching_col.cast[DType.float32](),
        )
