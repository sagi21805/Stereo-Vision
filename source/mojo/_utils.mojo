# TODO understand how to make better


fn numpy_data_pointer_i8(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.int8]:
    return DTypePointer[DType.int8](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<si8>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn numpy_data_pointer_i16(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.int16]:
    return DTypePointer[DType.int16](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<si16>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn numpy_data_pointer_i32(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.int32]:
    return DTypePointer[DType.int32](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<si32>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn numpy_data_pointer_i64(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.int64]:
    return DTypePointer[DType.int64](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<si64>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


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


fn numpy_data_pointer_ui64(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.uint64]:
    return DTypePointer[DType.uint64](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<ui64>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn numpy_data_pointer_f16(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.float16]:
    return DTypePointer[DType.float16](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<f16>>`
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


fn numpy_data_pointer_f64(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.float64]:
    return DTypePointer[DType.float64](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<f64>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn numpy_data_pointer_bf16(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.bfloat16]:
    return DTypePointer[DType.bfloat16](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<bf16>>`
        ](
            SIMD[DType.index, 1](
                numpy_array.__array_interface__["data"][0].__index__()
            ).value
        )
    )


fn numpy_data_pointer_tf32(
    numpy_array: PythonObject,
) raises -> DTypePointer[DType.tensor_float32]:
    return DTypePointer[DType.tensor_float32](
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type.`!kgen.pointer<scalar<tf32>>`
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

    fn horizontal(inout self) -> SIMD[type, 1]:
        return self.fov[0]

    fn vertical(inout self) -> SIMD[type, 1]:
        return self.fov[1]


struct Pose2d[type: DType]:
    var pose: SIMD[type, 2]

    fn __init__(inout self):
        self.pose = SIMD[type, 2](0, 0)

    fn __init__(inout self, row: SIMD[type, 1], col: SIMD[type, 1]):
        self.pose = SIMD[type, 2](row, col)

    fn row(inout self) -> SIMD[type, 1]:
        return self.pose[0]

    fn col(inout self) -> SIMD[type, 1]:
        return self.pose[1]


struct Size[type: DType]:
    var size: SIMD[type, 2]

    fn __init__(inout self):
        self.size = SIMD[type, 2](0, 0)

    fn __init__(inout self, width: SIMD[type, 1], height: SIMD[type, 1]):
        self.size = SIMD[type, 2](width, height)

    fn width(inout self) -> SIMD[type, 1]:
        return self.size[0]

    fn height(inout self) -> SIMD[type, 1]:
        return self.size[1]
