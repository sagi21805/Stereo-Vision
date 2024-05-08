from time import now
from math import clamp
from python import Python
from source.mojo._utils import *
from source.mojo.stereo import *
from source.mojo.camera import *
from time import now
import time


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
#TODO rememmber to free window

fn create_window[window_size: Int](np: DTypePointer[DType.uint8], inout shape: Pose2d[DType.int32]) -> DTypePointer[DType.uint8]:
    
    var window = DTypePointer[DType.uint8].alloc((shape.row() * shape.col()).__int__())
    var movementRows = shape.row() // window_size
    var movementCols = shape.col() // window_size
    # var offset = 1 - window_size
    var count = 0
    for img_row in range(movementRows):
        # offset += window_size - 1
        for img_col in range(movementCols):
            for window_row in range(window_size):
                for window_col in range(window_size): 
                    window[count] = np[window_col + window_row*shape.col() + img_col*window_size + img_row*shape.col()*window_size] 
                    count+=1

    return window

fn main() raises:
    Python.add_to_path("./source/python")
    var py = Python.import_module("_utils")
    var cv2 = Python.import_module("cv2")
    alias first_window = 0
    alias second_window = 1
    alias window_size = 2
    # print(empty_arr)
    
    
    


    var pose = Pose2d[DType.int32](1924, 2864)

    # var im1 = py.get_test_arr(0)
    var im1 = cv2.cvtColor(cv2.imread("data/im0-min.jpeg"), cv2.COLOR_BGR2GRAY)
    var p = numpy_data_pointer_ui8(im1)
    var array = create_window[2](p, pose)

    # for i in range(100):
    #     print(p[i])
    # print("started")
    # var t = now()
    var arr = py.get_window_view(py.read_image("data/im0-min.jpeg"), 2, 0)
    var p2 = numpy_data_pointer_ui8(arr)
    # print("time", now() - t)
    for i in range(1000):
        print(array[i] - p2[i])
    # print(im1)

    # var win2 = numpy_data_pointer_ui8(
    #     py.get_window_view(
    #         py.read_image("data/im1-min.jpeg"), window_size, second_window
    #     )
    # )
    # # var test = numpy_data_pointer_ui8(py.get_window_view(py.get_test_arr(second_window), window_size, second_window))
    # # var first = win1.load[width = 64]()
    # # var second = win1.load[width = 64]()
    # var t = now()
    # var err: UInt32 = 0
    # for i in range(0, 10000, window_size * window_size):
    #     var first = win1.load[width = window_size * window_size](i)
    #     var second = win2.load[width = window_size * window_size](i)
    #     err = math.abs(first - second).cast[DType.uint32]().reduce_add()
    # print(now() - t)
    # print(err)
