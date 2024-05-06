# TODO understand how to make better

alias numpy_array = PythonObject
alias video_capture = PythonObject
alias python_lib = PythonObject


fn numpy_data_pointer_ui8(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.uint8]:
    return DTypePointer[DType.uint8](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<ui8>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn numpy_data_pointer(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.uint32]:
    return DTypePointer[DType.uint32](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<ui32>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn get_window_view[
    window_size: Int, window_number: Int
](img: PythonObject, python_utils: PythonObject) raises -> DTypePointer[
    DType.uint8
]:
    return numpy_data_pointer_ui8(
        python_utils.get_window_view(img, window_size, window_number)
    )


struct FOV[type: DType]:
    var fov: SIMD[type, 2]

    fn __init__(inout self):
        self.fov = SIMD[type, 2](0, 0)

    fn __init__(inout self, horizontal: SIMD[type, 1], vertical: SIMD[type, 1]):
        self.fov = SIMD[type, 2](horizontal, vertical)

    fn __init__(inout self, angles: SIMD[type, 2]):
        self.fov = angles

    fn __copyinit__(inout self, other: FOV[self.type]):
        self.fov = other.fov

    fn horizontal(inout self) -> SIMD[type, 1]:
        return self.fov[0]

    fn vertical(inout self) -> SIMD[type, 1]:
        return self.fov[1]


struct Pose2d[type: DType]:
    var pose: SIMD[type, 2]

    fn __init__(inout self):
        self.pose = SIMD[type, 2](0, 0)

    fn __init__(inout self, pose: SIMD[type, 2]):
        self.pose = pose

    fn __init__(inout self, row: SIMD[type, 1], col: SIMD[type, 1]):
        self.pose = SIMD[type, 2](col, row)

    fn __copyinit__(inout self, other: Pose2d[self.type]):
        self.pose = other.pose

    fn row(inout self) -> SIMD[type, 1]:
        return self.pose[1]

    fn col(inout self) -> SIMD[type, 1]:
        return self.pose[0]


struct Size[type: DType]:
    var size: SIMD[type, 2]

    fn __init__(inout self):
        self.size = SIMD[type, 2](0, 0)

    fn __init__(inout self, width: SIMD[type, 1], height: SIMD[type, 1]):
        self.size = SIMD[type, 2](width, height)

    fn __copyinit__(inout self, other: Size[self.type]):
        self.size = other.size

    fn width(inout self) -> SIMD[type, 1]:
        return self.size[0]

    fn height(inout self) -> SIMD[type, 1]:
        return self.size[1]

    fn area(inout self) -> Int:
        return SIMD[DType.int32, 1](self.width() * self.height()).value
