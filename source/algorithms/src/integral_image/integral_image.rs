use super::integral_image_neon::neon_integral_image;
use rayon::prelude::*;
use ndarray::{Array2, Shape};
use pyo3::prelude::*;
use numpy::*;

#[pyclass]
pub struct IntegralImage {
    #[pyo3(get, set)]
    pub integral_image: Py<PyArray2<u32>>,
}

#[pymethods]
impl IntegralImage {

    #[new]
    pub fn new(py: Python, source_image: PyReadonlyArray2<u8>) -> Self {
        let integral_image = neon_integral_image(
            source_image.as_slice().expect("Failed to transform numpy array into slice"),
            source_image.shape()[1],
            source_image.shape()[0],
        );

        // println!("width: {}, height: {}", source_image.shape()[1], source_image.shape()[0]);

        let shape = (
            source_image.shape()[0] + 1,
            source_image.shape()[1] + 1,
        );

        let integral_array = Array2::from_shape_vec(
            shape, 
            integral_image
        ).expect("Failed to create integral image array");

        IntegralImage {
            integral_image: PyArray2::from_array(
                py, &integral_array
            ).to_owned()
        }
    }

    
    pub fn sliding_window_multi_threshold(
            &self,
            py: Python,
            window_size: usize,
            thresholds_num: usize,
        ) -> Py<PyArray2<u8>> {
        
            let arr = self.integral_image.as_ref(py);
            let integral_width: usize = arr.shape()[1];
            let integral_height: usize = arr.shape()[0];

            let integral_vec = arr.to_vec().unwrap();

            let movement_rows = integral_height - window_size;
            let movement_cols = integral_width - window_size;
    
            let thresholds: Vec<u8> = (0..=255).step_by(255 / (thresholds_num - 1)).collect(); // assuming 255 is the max value of an image
            let devisor: usize = window_size * window_size * 255 / thresholds_num;
    
            let mut out = vec![0u8; movement_cols * movement_rows];
    
            out.par_iter_mut()
                .enumerate()
                .for_each(|(index, out_pixel)| {
                let img_row = index / movement_cols;
                let img_col = index % movement_cols;
                
                let sum: u32 = rectangle_sum(
                        &integral_vec,
                        integral_width,
                        img_col, 
                        img_row, 
                        window_size, 
                        window_size
                ).saturating_sub(1);

        
                *out_pixel = thresholds[(sum / devisor as u32) as usize];
            });
    
            let integral_array = Array2::from_shape_vec(
                (movement_rows, movement_cols), 
                out
            ).expect("Failed to create integral image array");
    
            PyArray2::from_array(py, &integral_array).to_owned()
    }
}

pub fn rectangle_sum(
    integral_image: &Vec<u32>,
    integral_width: usize, 
    x: usize, 
    y: usize, 
    width: usize, 
    height: usize
) -> u32 {
    // Ensure the rectangle coordinates and dimensions are within the bounds of the integral image;
         
    let top_left = integral_image[y * integral_width + x];
    let top_right = integral_image[y * integral_width + x + width];
    let bottom_left = integral_image[(y + height) * integral_width + x];
    let bottom_right = integral_image[(y + height) * integral_width + x + width];

    // println!("tl: {}, tr: {}, bl: {}, br: {}", top_left, top_right, bottom_left, bottom_right);

    bottom_right + top_left - top_right - bottom_left
}               
                