use numpy::{PyArray2, PyReadonlyArray2};
use ndarray::Array2;
use rayon::prelude::*;
use pyo3::prelude::*;

pub fn _sliding_window_multi_threshold(
    img: &[u8],
    rows: usize,
    cols: usize,
    window_size: usize,
    thresholds_num: usize,
) -> Vec<u8> {
    let movement_rows = rows - window_size + 1;
    let movement_cols = cols - window_size + 1;

    let thresholds: Vec<u8> = (0..=255).step_by(255 / (thresholds_num - 1)).collect(); // assuming 255 is the max value of an image
    let devisor = window_size * window_size * 255 / thresholds_num;

    let mut out = vec![0u8; movement_cols * movement_rows];

    out.par_iter_mut()
        .enumerate()
        .for_each(|(index, out_pixel)| {
            let img_row = index / movement_cols;
            let img_col = index % movement_cols;
            let mut sum: u32 = 0;

            for window_row in 0..window_size {
                for window_col in 0..window_size {
                    sum += img[window_col + img_col + (window_row + img_row) * cols] as u32;
                }
            }

            *out_pixel = thresholds[(sum.saturating_sub(1) / devisor as u32) as usize];
        });
    out
}

#[pyfunction]
pub fn sliding_window_multi_threshold(
    py: Python,
    img: PyReadonlyArray2<u8>,
    window_size: usize,
    thresholds_num: usize,
) -> Py<PyArray2<u8>> {
    
    let movement_rows = img.shape()[0] - window_size + 1;
    let movement_cols = img.shape()[1] - window_size + 1;

    let out = _sliding_window_multi_threshold(
        img.as_slice().unwrap(),
        img.shape()[0], 
        img.shape()[1], 
        window_size, 
        thresholds_num
    );

    let integral_array = Array2::from_shape_vec(
        (movement_rows, movement_cols), 
        out
    ).expect("Failed to create integral image array");

    PyArray2::from_array(py, &integral_array).to_owned()
}