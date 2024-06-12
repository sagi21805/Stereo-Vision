mod utils;
mod camera; 
mod stereo;
use camera::cam_utils::{CamParameters, CamSettings};
use camera::Camera;
use std::{thread, time::Duration};

fn main() {
    let settings = CamSettings {
        frame_width: 1280,
        frame_height: 720,
        ..Default::default()
    };
    let params = CamParameters::empty();

    println!("{}", params.angles.x);

    let mut cam = Camera::new(0, settings, params);
    
    for _ in 0..20 {
        cam.update_frame();
        cam.write_frames();
        thread::sleep(Duration::from_millis(100));
        let slice = utils::mat_to_slice(&cam.frame).unwrap();
        println!("{}", slice[0]);
    }

    // println!("{}", vec[0]);
}

