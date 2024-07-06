use std::ptr::write_bytes;
use std::arch::aarch64::*;
use rayon::prelude::*;
use pyo3::prelude::*;
use numpy::*;
use ndarray::Array2;
pub struct IntegralImage {
    integral_image: Vec<u32>,
    integral_width: usize,
    integral_height: usize,
}

impl IntegralImage {

    pub fn new(source_image: &[u8], width: usize, height: usize) -> Self {
        let integral_width = width + 1;
        let integral_height = height + 1;
        let integral_image = neon_integral_image(source_image, width, height);

        IntegralImage {
            integral_image,
            integral_width,
            integral_height
        }
    }

    pub fn rectangle_sum(&self, x: usize, y: usize, width: usize, height: usize) -> u32 {
        // Ensure the rectangle coordinates and dimensions are within the bounds of the integral image
        assert!(x + width < self.integral_width);
        assert!(y + height < self.integral_height);

        let top_left = self.integral_image[y * self.integral_width + x];
        let top_right = self.integral_image[y * self.integral_width + x + width];
        let bottom_left = self.integral_image[(y + height) * self.integral_width + x];
        let bottom_right = self.integral_image[(y + height) * self.integral_width + x + width];

        bottom_right + top_left - top_right - bottom_left
    }

    pub fn sliding_window_multi_threshold(
        &self,
        window_size: usize,
        thresholds_num: usize,
    ) -> Vec<u8> {

        let movement_rows = self.integral_height - window_size + 1;
        let movement_cols = self.integral_width - window_size + 1;
    
        let thresholds: Vec<u8> = (0..255).step_by(255 / thresholds_num).collect(); // assuming 255 is the max value of an image
        let devisor = window_size * window_size * 255 / thresholds_num;
    
        let mut out = vec![0u8; movement_cols * movement_rows];
    
        out.par_iter_mut()
            .enumerate()
            .for_each(|(index, out_pixel)| {
                let img_row = index / movement_cols;
                let img_col = index % movement_cols;
                let sum: u32 = self.rectangle_sum(
                    img_col, 
                    img_row, 
                    window_size, 
                    window_size
                );
    
                
                *out_pixel = thresholds[(sum / devisor as u32) as usize];
            });
        out
    }
}



pub fn neon_integral_image(source_image: &[u8], width: usize, height: usize) -> Vec::<u32>{
    // integral images add an extra row and column of 0s to the image
    
    let integral_image_width = width + 1;
    let integral_image_height = height + 1;

    let mut integral_image = vec![0u32; integral_image_width * integral_image_height];

    // 0 out the first row
    unsafe {
        write_bytes(integral_image.as_mut_ptr(), 0, integral_image_width);
    }

    // pointer to the start of the integral image, skipping past the first row and column
    let integral_image_start = integral_image.as_mut_ptr().wrapping_add(integral_image_width + 1);

    let zero_vec = unsafe { vdupq_n_u16(0) };

    // prefix sum for rows
    for i in 0..height {
        let mut carry = unsafe { vdupq_n_u32(0) };
        let source_row_offset = i * width;
        let integral_row_offset = i * integral_image_width;

        // 0 out the start of every row, starting from the 2nd
        integral_image[integral_image_width + integral_row_offset] = 0;

        let mut j = 0;

        // iterate over the row in 16 byte chunks
        while j + 16 <= width {
            let elements = unsafe { vld1q_u8(source_image.as_ptr().wrapping_add(source_row_offset + j)) };

            let low_elements8 = unsafe { vget_low_u8(elements) };
            let mut low_elements16 = unsafe { vmovl_u8(low_elements8) };
            let high_elements8 = unsafe { vget_high_u8(elements) };
            let mut high_elements16 = unsafe { vmovl_u8(high_elements8) };

            low_elements16 = unsafe { vaddq_u16(low_elements16, vextq_u16(zero_vec, low_elements16, 7)) };
            low_elements16 = unsafe { vaddq_u16(low_elements16, vextq_u16(zero_vec, low_elements16, 6)) };
            low_elements16 = unsafe { vaddq_u16(low_elements16, vextq_u16(zero_vec, low_elements16, 4)) };

            high_elements16 = unsafe { vaddq_u16(high_elements16, vextq_u16(zero_vec, high_elements16, 7)) };
            high_elements16 = unsafe { vaddq_u16(high_elements16, vextq_u16(zero_vec, high_elements16, 6)) };
            high_elements16 = unsafe { vaddq_u16(high_elements16, vextq_u16(zero_vec, high_elements16, 4)) };

            let low_elements_of_low_prefix32 = unsafe { vaddq_u32(vmovl_u16(vget_low_u16(low_elements16)), carry) };
            unsafe { vst1q_u32(integral_image_start.wrapping_add(integral_row_offset + j), low_elements_of_low_prefix32) };

            let high_elements_of_low_prefix32 = unsafe { vaddq_u32(vmovl_u16(vget_high_u16(low_elements16)), carry) };
            unsafe { vst1q_u32(integral_image_start.wrapping_add(integral_row_offset + j + 4), high_elements_of_low_prefix32) };

            let mut prefix_sum_last_element = unsafe { vgetq_lane_u32(high_elements_of_low_prefix32, 3) };
            carry = unsafe { vdupq_n_u32(prefix_sum_last_element) };

            let low_elements_of_high_prefix32 = unsafe { vaddq_u32(vmovl_u16(vget_low_u16(high_elements16)), carry) };
            unsafe { vst1q_u32(integral_image_start.wrapping_add(integral_row_offset + j + 8), low_elements_of_high_prefix32) };

            let high_elements_of_high_prefix32 = unsafe { vaddq_u32(vmovl_u16(vget_high_u16(high_elements16)), carry) };
            unsafe { vst1q_u32(integral_image_start.wrapping_add(integral_row_offset + j + 12), high_elements_of_high_prefix32) };

            prefix_sum_last_element = unsafe { vgetq_lane_u32(high_elements_of_high_prefix32, 3) };
            carry = unsafe { vdupq_n_u32(prefix_sum_last_element) };

            j += 16;
        }

        // now handle the remainders (< 16 pixels)
        let mut prefix_sum_last_element = 0;
        for k in j..width {
            prefix_sum_last_element += source_image[source_row_offset + k] as u32;
            unsafe { *integral_image_start.wrapping_add(integral_row_offset + k) = prefix_sum_last_element };
        }
    }

    // prefix sum for columns, using height - 1 since we're taking pairs of rows
    for i in 0..height - 1 {
        let mut j = 0;
        let integral_row_offset = i * integral_image_width;

        while j + 16 <= width {
            let row1_elements32 = unsafe { vld1q_u32(integral_image_start.wrapping_add(integral_row_offset + j)) };
            let row2_elements32 = unsafe { vld1q_u32(integral_image_start.wrapping_add(integral_row_offset + integral_image_width + j)) };
            let row2_elements32 = unsafe { vqaddq_u32(row1_elements32, row2_elements32) };
            unsafe { vst1q_u32(integral_image_start.wrapping_add(integral_row_offset + integral_image_width + j), row2_elements32) };

            let row1_elements32 = unsafe { vld1q_u32(integral_image_start.wrapping_add(integral_row_offset + j + 4)) };
            let row2_elements32 = unsafe { vld1q_u32(integral_image_start.wrapping_add(integral_row_offset + integral_image_width + j + 4)) };
            let row2_elements32 = unsafe { vqaddq_u32(row1_elements32, row2_elements32) };
            unsafe { vst1q_u32(integral_image_start.wrapping_add(integral_row_offset + integral_image_width + j + 4), row2_elements32) };

            let row1_elements32 = unsafe { vld1q_u32(integral_image_start.wrapping_add(integral_row_offset + j + 8)) };
            let row2_elements32 = unsafe { vld1q_u32(integral_image_start.wrapping_add(integral_row_offset + integral_image_width + j + 8)) };
            let row2_elements32 = unsafe { vqaddq_u32(row1_elements32, row2_elements32) };
            unsafe { vst1q_u32(integral_image_start.wrapping_add(integral_row_offset + integral_image_width + j + 8), row2_elements32) };

            let row1_elements32 = unsafe { vld1q_u32(integral_image_start.wrapping_add(integral_row_offset + j + 12)) };
            let row2_elements32 = unsafe { vld1q_u32(integral_image_start.wrapping_add(integral_row_offset + integral_image_width + j + 12)) };
            let row2_elements32 = unsafe { vqaddq_u32(row1_elements32, row2_elements32) };
            unsafe { vst1q_u32(integral_image_start.wrapping_add(integral_row_offset + integral_image_width + j + 12), row2_elements32) };

            j += 16;
        }

        // now handle the remainders
        for k in j..width {
            unsafe { *integral_image_start.wrapping_add(integral_row_offset + integral_image_width + k) += *integral_image_start.wrapping_add(integral_row_offset + k) };
        }
    }

    return integral_image;
}



#[pyclass]
pub struct RustIntegralImage {
    inner: IntegralImage,
}

#[pymethods]
impl RustIntegralImage {

    #[new]
    fn new(source_image: PyReadonlyArray2<u8>) -> Self {
        RustIntegralImage {
            inner: IntegralImage::new(
                source_image.as_slice().unwrap(), 
                source_image.shape()[0], 
                source_image.shape()[1]
            )
        }
    }

    #[getter]
    fn width(&self) -> usize {
        self.inner.integral_width
    }

    #[getter]
    fn height(&self) -> usize {
        self.inner.integral_height
    }

    #[doc = "doc"]
    #[pyo3(text_signature = "(x: int, y: int, width: int, height: int)")]
    fn sliding_window_multi_threshold(
        &self, 
        py: Python,
        window_size: usize, 
        thresholds_num: usize
    ) -> PyResult<Py<PyArray2<u8>>> {
        let img = self.inner.sliding_window_multi_threshold(window_size, thresholds_num);

        let shape = (
            self.height() - window_size + 1,
            self.width() - window_size + 1,
        );

        let array = Array2::from_shape_vec(shape, img.to_owned()).unwrap();

        Ok(PyArray2::from_array(py, &array).to_owned())
    }
}