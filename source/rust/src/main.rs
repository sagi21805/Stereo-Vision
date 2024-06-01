use opencv::{prelude::*, Error};
use opencv::videoio::{self, VideoCapture, VideoWriter, CAP_ANY};
use opencv::imgcodecs;
use opencv::imgcodecs::{IMWRITE_JPEG_QUALITY};
use opencv::core;
mod camera;
use camera::cam_utils::CamSettings;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Open the default camera (usually the first one)
    let mut cam: VideoCapture = VideoCapture::new(0, CAP_ANY)?; // 0 is the index of the camera
    if !VideoCapture::is_opened(&cam)? {
        panic!("Unable to open the camera");
    }

    let settings = CamSettings::default();

    // Set the camera's fourcc codec to MJPG (Motion JPEG)
    let fourcc_code = VideoWriter::fourcc('M', 'J', 'P', 'G')? as f64;
    
    let _ = cam.set(videoio::CAP_PROP_FOURCC, fourcc_code);

    let mut frame = Mat::default();
    cam.read(&mut frame)?;

    if frame.empty() {
        Err("Unable to capture frame")?;
    }

    let mut buf: core::Vector<u8> = core::Vector::<u8>::new();
    let params: core::Vector<i32> = core::Vector::from(vec![IMWRITE_JPEG_QUALITY, 90]); // JPEG quality 90
    imgcodecs::imencode(".jpg", &frame, &mut buf, &params)?;

    // Convert the OpenCV vector to a Rust Vec<u8> without copying items
    let vec: Vec<u8> = buf.to_vec();

    // Print the length of the captured frame in bytes
    println!("Captured frame length: {}", vec.len());

    // Optionally, write the vector to a file to verify the result
    std::fs::write("output.jpg", &vec)?;

    Ok(())
}
