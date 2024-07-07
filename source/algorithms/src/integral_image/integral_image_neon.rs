use std::ptr::write_bytes;
use std::arch::aarch64::*;

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

