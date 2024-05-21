import math

alias numpy_array = PythonObject
alias video_capture = PythonObject
alias python_lib = PythonObject
alias pi_over_2 = 1.57079632679489661923
alias UINT8_C = 0
alias UINT16 = 1
alias UINT32_C = 2
alias FLOAT32_C = 3


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


fn numpy_data_pointer_ui16(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.uint16]:
    return DTypePointer[DType.uint16](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<ui16>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn numpy_data_pointer_ui32(
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


fn numpy_data_pointer_f32(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.float32]:
    return DTypePointer[DType.float32](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<f32>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn repeat_elements_ui16[
    v_size: Int, times: Int
](
    p: DTypePointer[DType.uint16],
    python_utils: python_lib,
) raises -> SIMD[
    DType.uint16, v_size * times
]:
    var arr = python_utils.ptr_to_numpy(p.address.__int__(), UINT16, (v_size,))
    var simd = numpy_data_pointer_ui16(
        python_utils.repeat_elements(arr, times)
    ).load[width = v_size * times]()
    return simd


# potintial big imporvement, there may be copying on the return
fn repeat_elements_ui32[
    v_size: Int, times: Int
](
    p: DTypePointer[DType.uint32],
    python_utils: python_lib,
) raises -> SIMD[
    DType.uint32, v_size * times
]:
    var arr = python_utils.ptr_to_numpy(
        p.address.__int__(), UINT32_C, (v_size,)
    )
    var simd = numpy_data_pointer_ui32(
        python_utils.repeat_elements(arr, times)
    ).load[width = v_size * times]()
    return simd


fn repeat_elements_f32[
    v_size: Int, times: Int
](
    p: DTypePointer[DType.float32],
    python_utils: python_lib,
) raises -> SIMD[
    DType.float32, v_size * times
]:
    var arr = python_utils.ptr_to_numpy(
        p.address.__int__(), FLOAT32_C, (v_size,)
    )
    var simd = numpy_data_pointer_f32(
        python_utils.repeat_elements(arr, times)
    ).load[width = v_size * times]()
    return simd


fn closet_power_of_2[number: Int]() -> Int:
    return math.pow[DType.int32, 1](
        2, 
        math.log2(SIMD[DType.float32, 1](number)).__int__() + 1).__int__()



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
