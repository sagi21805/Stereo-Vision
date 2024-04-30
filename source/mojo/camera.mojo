from memory import memcpy
from time import now
from math import clamp
from python import Python

fn numpy_data_pointer[type: DType](numpy_array: PythonObject) raises -> DTypePointer[DType.float16]:
    return DTypePointer[DType.float16](
                __mlir_op.`pop.index_to_pointer`[
                    _type=__mlir_type.`!kgen.pointer<scalar<f16>>`
                ](
                    SIMD[DType.index,1](numpy_array.__array_interface__['data'][0].__index__()).value
                )
            )

fn main():
    print(DType.float16.)