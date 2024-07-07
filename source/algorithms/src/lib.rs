#[macro_use]
mod marcos;
mod integral_image;
mod simd;
mod window_filters;

use pyo3::prelude::*;
use window_filters::multi_threshold::__pyo3_get_function_sliding_window_multi_threshold;

#[pymodule]
fn algorithms(py: Python, m: &PyModule) -> PyResult<()> {
    m.add_class::<integral_image::integral_image::IntegralImage>()?;
    m.add_function(wrap_pyfunction!(sliding_window_multi_threshold, m)?)?;
    Ok(())
}

#[cfg(test)]
mod tests {

    use crate::integral_image::{
        self, 
        integral_image_neon::neon_integral_image,
        integral_image::rectangle_sum
    };

    use ndarray::Array2;
    use pyo3::Python;
    #[test]
    fn test_integral_sum() {
        let source_image: Vec<u8> = vec![
            1, 2, 3, 4, 
            5, 6, 7, 8,
            9, 10, 11, 12,
            13, 14, 15, 16
        ];

        let width = 4;
        let height = 4;

        let integral_image = neon_integral_image(
            source_image.as_slice(),
             width, 
             height
        );

        for i in 0..height+1 {
            for j in 0..width+1 {
                print!("{} ", integral_image[i * (width+1) + j]);
            }
            println!();
        }

        let x = 0;
        let y = 0;
        let rect_width = 3;
        let rect_height = 2;

        let sum = rectangle_sum(
            &integral_image,
            width + 1,
            x, 
            y, 
            rect_width,
            rect_height
        );
        assert_eq!(sum, 24);
    }
}