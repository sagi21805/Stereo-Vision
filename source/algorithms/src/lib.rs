#[macro_use]
mod marcos;
mod integral_image;
mod simd;
mod window_filters;

use ndarray::Array2;
use numpy::*;
use pyo3::prelude::*;

#[pyclass]
struct MyClass {
    value: i32,
}

#[pymethods]
impl MyClass {
    #[new]
    fn new(value: i32) -> Self {
        MyClass { value }
    }

    #[getter]
    fn get_value(&self) -> PyResult<i32> {
        Ok(self.value)
    }
}


#[pymodule]
fn algorithms(_py: Python<'_>, m: &PyModule) -> PyResult<()> {
    #[pyfn(m)]
    #[doc = "doc"]
    #[pyo3(
        text_signature = "(arr1: numpy.ndarray[numpy.uint8], arr2: numpy.ndarray[numpy.uint8]) -> numpy.ndarray[numpy.uint16]"
    )]
    fn add_arrays(
        py: Python,
        a: PyReadonlyArray1<u8>,
        b: PyReadonlyArray1<u8>,
    ) -> PyResult<Py<PyArray1<u16>>> {
        Ok(PyArray1::from_vec(
            py,
            simd::add_slices_u8_u8_u16(a.as_slice().unwrap(), b.as_slice().unwrap()),
        )
        .to_owned())
    }

    #[pyfn(m)]
    #[doc = "doc"]
    #[pyo3(
        text_signature = "(image: numpy.ndarray[numpy.uint8], window_size: int, thresh: int) -> numpy.ndarray[numpy.uint8]"
    )]
    fn sliding_window_threshold(
        py: Python,
        img: PyReadonlyArray2<u8>,
        window_size: usize,
        thresh: u8,
    ) -> PyResult<Py<PyArray2<u8>>> {
        let v = window_filters::sliding_window_threshold(
            img.as_slice().unwrap(),
            img.shape()[0],
            img.shape()[1],
            window_size,
            thresh,
        );

        let shape = (
            img.shape()[0] - window_size + 1,
            img.shape()[1] - window_size + 1,
        );

        let array = Array2::from_shape_vec(shape, v.to_owned()).unwrap();

        Ok(PyArray2::from_array(py, &array).to_owned())
    }

    #[pyfn(m)]
    #[doc = "doc"]
    #[pyo3(
        text_signature = "(image: numpy.ndarray[numpy.uint8], window_size: int, thresholds_num: int) -> numpy.ndarray[numpy.uint8]"
    )]
    fn sliding_window_multi_threshold(
        py: Python,
        img: PyReadonlyArray2<u8>,
        window_size: usize,
        thresholds_num: usize,
    ) -> PyResult<Py<PyArray2<u8>>> {
        let v = window_filters::sliding_window_multi_threshold(
            img.as_slice().unwrap(),
            img.shape()[0],
            img.shape()[1],
            window_size,
            thresholds_num,
        );

        let shape = (
            img.shape()[0] - window_size + 1,
            img.shape()[1] - window_size + 1,
        );

        let array = Array2::from_shape_vec(shape, v.to_owned()).unwrap();

        Ok(PyArray2::from_array(py, &array).to_owned())
    }

    m.add_class::<integral_image::RustIntegralImage>()?;
    m.add_class::<MyClass>()?;


    Ok(())
}

#[cfg(test)]
mod tests {
    use super::integral_image::*;

    #[test]
    fn test_integral_image() {
        let source_image: Vec<u8> = vec![
            1, 2, 3, 4, 
            5, 6, 7, 8, 
            9, 10, 11, 12, 
            13, 14, 15, 16
        ];

        let width = 4;
        let height = 4;

        let integral_image = IntegralImage::new(
            source_image.as_slice(), 
            width, 
            height
        );

        let x = 2;
        let y = 1;
        let rect_width = 2;
        let rect_height = 2;

        let (sum, duration) = time_function!(
            integral_image.rectangle_sum(x, y, rect_width, rect_height)
        );
        println!("time: {:?}", duration);
        assert_eq!(sum, 34);
    }

    
}
