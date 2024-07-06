use rayon::prelude::*;
use std::arch::aarch64::*;

const SIMD_SIZE_BYTE: usize = 16;
// Function to sum two slices of u8 into a SIMD vector of u16
pub fn add_slices_u8_u8_u16(a: &[u8], b: &[u8]) -> Vec<u16> {
    assert_eq!(a.len(), b.len(), "a and b are not in the same length");

    let size: usize = a.len();
    let step_size = SIMD_SIZE_BYTE / std::mem::size_of::<u16>(); // Size in elements of uint16x8_t
    let last_index = (size / step_size) * step_size;

    let mut c = vec![0; size];

    for i in (0..size).step_by(step_size) {
        unsafe {
            // Load 8 uint8_t elements from array1 and array2
            let neon1 = vld1_u8(a.as_ptr().add(i));
            let neon2 = vld1_u8(b.as_ptr().add(i));
            let sum = vaddl_u8(neon1, neon2);
            vst1q_u16(c.as_mut_ptr().add(i), sum);
        }
    }

    for i in last_index..size {
        c[i] = a[i] as u16 + b[i] as u16;
    }

    return c;
}
