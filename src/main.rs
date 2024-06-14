#[macro_use]
mod utils;
mod camera;
mod stereo;
use std::thread;
use std::time::Duration;
use stereo::Stereo;
use utils::camera::{CamParameters, CamSettings};

fn main() {
    let settings = CamSettings {
        frame_width: 1280,
        frame_height: 800,
        ..Default::default()
    };
    let params = CamParameters::empty();

    let mut stereo = Stereo::new(0, 2, 0.0, &settings, &params);
    // println!("{}", vec[0]);
    loop {
        stereo.update_frame();
        stereo.save_frame();
        thread::sleep(Duration::from_millis(200));
    }
}
