from source.mojo._utils import FOV
import math

@value
struct CamParameters:

    var focal_length_x: Int
    var focal_length_y: Int
    var center_x: Int
    var center_y: Int
    var horizontal_angle: Float32
    var vertical_angle: Float32
    var angle_pixel_ratio: FOV[DType.float32]

    fn __init__(
        inout self,
        focal_length_x: Int,
        focal_length_y: Int,
        frame_width: Int,
        frame_height: Int,
        center_x: Int = -1,
        center_y: Int = -1,
        ):


        self.focal_length_x = focal_length_x
        self.focal_length_y = focal_length_y
        self.center_x = center_x
        self.center_y = center_y

        self.horizontal_angle = 2 * math.atan[DType.float32, 1](
            (SIMD[DType.float32, 1](frame_width))
        ) / (2 * focal_length_x)

        self.vertical_angle = 2 * math.atan(
            SIMD[DType.float32, 1](frame_height)
        ) / (2 * focal_length_y)

        self.angle_pixel_ratio = FOV[DType.float32](
                self.horizontal_angle / frame_width,
                self.vertical_angle / frame_height
        )
