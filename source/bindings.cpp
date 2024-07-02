#include <pybind11/pybind11.h>
#include "algorithms/include/window_filters.h"
#include <pybind11/numpy.h>

namespace py = pybind11;

void deleter(void* data){
    free(data);
}


template<typename T>
py::array_t<T> winodow_threshold(py::array_t<T> a, int32_t window_size, uint8_t threshold) {

    py::buffer_info a_info = a.request();
    
    const uint32_t final_rows = (a_info.shape[0] - window_size) + 1;
    const uint32_t final_cols = (a_info.shape[1] - window_size) + 1;

    T* p = slidingWindowThreshold(
        (T*) a_info.ptr, 
        a_info.shape[0], 
        a_info.shape[1], 
        window_size,
        threshold
    );

    py::capsule free_when_done((void*) p, deleter);

    return py::array_t<T>(
        {final_rows, final_cols}, 
        {final_cols * sizeof(T), sizeof(T)}, 
        p , free_when_done
    );

}

template<typename T>
py::array_t<T> window_multi_threshold(

        py::array_t<T> a, 
        int32_t window_size, 
        uint8_t thresholds_num

    ) {

    py::buffer_info a_info = a.request();
    
    const uint32_t final_rows = (a_info.shape[0] - window_size) + 1;
    const uint32_t final_cols = (a_info.shape[1] - window_size) + 1;

    T* p = slidingWindowMultiThreshold(
        (T*) a_info.ptr, 
        a_info.shape[0], 
        a_info.shape[1], 
        window_size,
        thresholds_num
    );

    py::capsule free_when_done((void*) p, deleter);

    return py::array_t<T>(
        {final_rows, final_cols}, 
        {final_cols * sizeof(T), sizeof(T)}, 
        p , free_when_done
    );

}

PYBIND11_MODULE(custom_algs, m) {
  
    m.def(
        "window_threshold", 
        &winodow_threshold<uint8_t>, 
        py::arg("img"), 
        py::arg("window_size"), 
        py::arg("thresh")
    );

    m.def(
        "window_multi_threshold", 
        &window_multi_threshold<uint8_t>, 
        py::arg("img"), 
        py::arg("window_size"), 
        py::arg("thresh_num")
    );

}