from python import Python
from source.mojo._utils import Size, FOV, Pose2d
from source.mojo.camera import Camera
import math


struct Stereo:
    var cam1: Camera
    var cam2: Camera
    var frame1: DTypePointer[DType.uint8]
    var frame2: DTypePointer[DType.uint8]
    var base_line: Float32  # mm
    var window_size: UInt32  # mm
    var windows_per: Pose2d[DType.uint32]
    var can_match: List[Bool]
    var depthMap: List[Float32]

    fn __init__[
        cam1: Camera,
        cam2: Camera,
        base_line: Float32,
        window_size: UInt32,
        windows_per: Pose2d[DType.uint32],
    ](inout self) raises:
        self.cam1 = cam1
        self.cam2 = cam2
        self.frame1 = self.cam1.get_frame()
        self.frame2 = self.cam2.get_frame()
        self.base_line = base_line
        self.window_size = window_size
        self.windows_per = Pose2d[DType.uint32](
            self.cam1.frame_size.size / window_size
        )
        self.can_match = List[Bool]()
        self.depthMap = List[Float32]()
        var num_of_pixels = self.cam1.frame_size.area()
        self.can_match.reserve(num_of_pixels)
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

    # fn windowMSE[window_size: Int](
    #     inout self,
    #     inout pose1: Pose2d[DType.float32],
    #     inout pose2: Pose2d[DType.float32],
    # ) -> Float32:
    #     var first_window: SIMD[DType.float32, window_size]
    #     var second_window: SIMD[DType.float32, window_size]

    #     for window_row in range(window_size):
    #         for window_col in range(window_size):
