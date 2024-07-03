use std::arch::aarch64::*;
use rayon::prelude::*;

const SIMD_SIZE_BYTE: usize = 16;
// Function to sum two slices of u8 into a SIMD vector of u16
pub fn add_slices_u8_u8_u16(a: &[u8], b: &[u8], c: &mut [u16]){
    assert_eq!(a.len(), b.len());
    assert_eq!(a.len(), c.len());

    let size = a.len();
    let step_size = SIMD_SIZE_BYTE / std::mem::size_of::<u16>(); // Size in elements of uint16x8_t
    println!("step size: {}", step_size);
    let mut i = 0;

    while i < size - step_size {

        unsafe {
            // Load 8 uint8_t elements from array1 and array2
            let neon1 = vld1_u8(a.as_ptr().add(i));
            let neon2 = vld1_u8(b.as_ptr().add(i));
            let sum = vaddl_u8(neon1, neon2);
            vst1q_u16(c.as_mut_ptr().add(i), sum);
        }
        i += step_size;
    }

    while i < size {
        c[i] = u16::from(a[i]) + u16::from(b[i]);
        i += 1;
    }

}


pub fn add_slices_u8_u8_u16_par(a: &[u8], b: &[u8], c: &mut [u16]) {
    assert_eq!(a.len(), b.len());
    assert_eq!(a.len(), c.len());

    let step_size = SIMD_SIZE_BYTE / std::mem::size_of::<u16>(); // Size in elements of uint16x8_t

    c.par_chunks_mut(step_size).enumerate().for_each(|(chunk_index, chunk)| {
        let start_index = chunk_index * step_size;

        unsafe {
            let neon1 = vld1_u8(a.as_ptr().add(start_index));
            let neon2 = vld1_u8(b.as_ptr().add(start_index));

            let sum = vaddl_u8(neon1, neon2);

            vst1q_u16(chunk.as_mut_ptr(), sum);
        }
    });

    c.iter_mut().enumerate().skip(a.len()).for_each(|(i, elem)| {
        *elem = u16::from(a[i]) + u16::from(b[i]);
    });
}