mod camera; 
mod utils;
use camera::cam_utils::{self, CamParameters, CamSettings};
use camera::Camera;
use std::{thread, time::Duration};

fn main() {
    let settings = CamSettings {
        frame_width: 1280,
        frame_height: 720,
        ..Default::default()
    };
    let params = CamParameters::empty();

    let mut cam = Camera::new(0, settings, params);
    
    for _ in 0..20 {
        cam.update_frame();
        cam.write_frames();
        thread::sleep(Duration::from_millis(100));
    }
    // println!("{}", vec[0]);
}

