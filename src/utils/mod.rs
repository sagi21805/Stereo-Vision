pub mod camera;
pub mod macros;
pub mod point;
use opencv::core::{Mat, Vector};
use opencv::imgcodecs::IMWRITE_PNG_COMPRESSION;
use opencv::prelude::*;
use std::rc::Rc;

pub fn mat_to_slice<'a>(mat: &Mat) -> Option<&'a [u8]> {
    // Check if the Mat is continuous
    if !mat.is_continuous() {
        return None;
    }

    let data_ptr = mat.data() as *const u8;
    let total = (mat.total() * mat.elem_size().unwrap()) as usize;
    println!("total size: {}", total);

    let m = unsafe { Rc::new(std::slice::from_raw_parts(data_ptr, total)) };


    Some(unsafe { std::slice::from_raw_parts(data_ptr, total) })
}

pub fn clac_histogram(img: &[u8]) -> Result<Vec<u32>, &str> {
    let mut histogram: Vec<u32> = vec![0; 256];
    img.iter().for_each(|x: &u8| histogram[*x as usize] += 1);
    println!(
        "histogram: {:?}",
        histogram.iter().enumerate().collect::<Vec<_>>()
    );
    Ok(histogram)
}

pub fn automatic_threshold(img: &[u8]) -> u8 {
    let histogram: Vec<u32> = clac_histogram(img).unwrap();
    print_histogram(&histogram);
    histogram
        .windows(3)
        .skip(1)
        .enumerate()
        .filter(|(i, win)| win[1] < win[0] && win[1] < win[2])
        .min_by_key(|&(i, val)| val)
        .unwrap()
        .0 as u8
}

pub fn save_frame(name: &str, img: &Mat) {
    let params = Vector::from_iter(vec![IMWRITE_PNG_COMPRESSION, 1]);
    opencv::imgcodecs::imwrite(&format!("test_frames/{}.png", name), img, &params).unwrap();
}

pub fn print_histogram(histogram: &Vec<u32>) {
    let avg: u32 = (histogram.iter().sum::<u32>() / histogram.len() as u32) as u32;
    for (i, item) in histogram.iter().enumerate() {
        println!("{}: {}", i, "#".repeat(((*item / avg) * 10) as usize + 1));
    }
}
