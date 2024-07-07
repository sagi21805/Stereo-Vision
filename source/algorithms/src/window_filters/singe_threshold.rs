use rayon::prelude::*;


pub fn sliding_window_threshold(
    img: &[u8],
    rows: usize,
    cols: usize,
    window_size: usize,
    threshold: u8,
) -> Vec<u8> {
    let movement_rows = rows - window_size + 1;
    let movement_cols = cols - window_size + 1;

    let thresh = threshold as usize * window_size * window_size;
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

            if sum as usize > thresh {
                *out_pixel = 255;
            }
        });

    out
}

