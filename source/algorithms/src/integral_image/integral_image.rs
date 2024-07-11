use super::integral_image_neon::neon_integral_image;
use rayon::prelude::*;
use ndarray::{Array2, Shape};
use pyo3::{ffi::Py_Finalize, prelude::*};
use numpy::*;

#[pyclass]
pub struct IntegralImage {
    #[pyo3(get, set)]
    pub source_image: Py<PyArray2<u8>>,
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

        let shape = (
            source_image.shape()[0] + 1,
            source_image.shape()[1] + 1,
        );

        let integral_array = Array2::from_shape_vec(
            shape, 
            integral_image
        ).expect("Failed to create integral image array");

        IntegralImage {
            source_image: PyArray2::from_array(
                py, &source_image.to_owned_array()).to_owned(),

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


            let integral_vec: Vec<u32> = arr.to_vec().unwrap();

            // println!("last: {:?}, sum: {}", integral_vec, integral_vec.iter().map(|&x| x as u64).sum::<u64>());

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

    pub fn adaptive_window_threshold(
        &self, 
        py: Python,
        window_size: usize,
        threshold: usize
    ) -> Py<PyArray2<u8>> {

            assert_eq!(window_size % 2, 1, "window_size must be odd");

            let integral_image = self.integral_image.as_ref(py);
            let integral_width: usize = integral_image.shape()[1];
            let integral_vec: Vec<u32> = integral_image.to_vec().unwrap();
            
            let image = self.source_image.as_ref(py);
            let height = image.shape()[0];
            let width = image.shape()[1];
            let image_slice = unsafe {image.as_slice().unwrap()};

            let final_height = height - window_size - 1;
            let final_width = width - window_size - 1;
            
            let mut out = vec![0u8; final_width * final_height];
            
            let window_items = window_size * window_size;
            
            out.par_iter_mut()
                .enumerate()
                .for_each(|(index, out_pixel)| {
                
                
                let img_row = index / final_width;
                let img_col = index % final_width;
                
                let sum: u32 = rectangle_sum(
                        &integral_vec,
                        integral_width,
                        img_col, 
                        img_row, 
                        window_size, 
                        window_size
                );

                let current_pixel = image_slice[
                    (img_row + (window_size / 2)) * width + (img_col + (window_size / 2))
                ];

                if current_pixel as usize * window_items >= 
                    sum as usize * (255 - threshold) / 255 {

                    *out_pixel = 255;

                }

            });
    
            let integral_array = Array2::from_shape_vec(
                (final_height, final_width), 
                out
            ).expect("Failed to create integral image array");
    
            PyArray2::from_array(py, &integral_array).to_owned()



    }

    // pub fn adaptive_window_threshold2(
    //     &self,
    //     py: Python, 
    //     window_size: usize, 
    //     threshold: usize
    // ) ->  Py<PyArray2<u8>> {

    //     let image = unsafe {
    //          self.source_image.as_ref(py).as_array() 
    //     };

    //     let int_img = unsafe {
    //         self.integral_image.as_ref(py).as_array()
    //     };

    //     let out_o,g

    //     PyArray2::from_array(py, &out_img).to_owned()

    // }
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
    // println!("final: {}", bottom_right as i32 + top_left as i32 - top_right as i32 - bottom_left as i32);
    bottom_right - top_right + top_left - bottom_left
}               
                