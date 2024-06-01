use opencv::prelude::*;
use opencv::videoio::{VideoCapture, VideoWriter,
    CAP_ANY, CAP_PROP_EXPOSURE, CAP_PROP_BRIGHTNESS, CAP_PROP_CONTRAST, CAP_PROP_AUTO_EXPOSURE,
    CAP_PROP_SATURATION, CAP_PROP_GAIN, CAP_PROP_FRAME_WIDTH, CAP_PROP_FRAME_HEIGHT, CAP_PROP_FOURCC};

pub struct CamSettings {
    auto_exposure: bool,
    exposure: i32,
    brightness: i32,
    contrast: i32,
    saturation: i32,
    gain: i32,
    frame_width: i32,
    frame_height: i32,
}

impl CamSettings {

    pub fn initialize_cap(&self, index: i32) -> VideoCapture {
        let mut cap = VideoCapture::new(index, CAP_ANY).unwrap(); 

        if !VideoCapture::is_opened(&cap).unwrap() {
            panic!("Unable to open the camera");
        }

        let fourcc = VideoWriter::fourcc('M', 'J', 'P', 'G').unwrap() as f64;
        cap.set(CAP_PROP_FOURCC, fourcc).unwrap();
        cap.set(CAP_PROP_AUTO_EXPOSURE, (3 - (self.auto_exposure as i32 * 2)) as f64).unwrap();
        cap.set(CAP_PROP_EXPOSURE, self.exposure as f64).unwrap();
        cap.set(CAP_PROP_BRIGHTNESS, self.brightness as f64).unwrap();
        cap.set(CAP_PROP_CONTRAST, self.contrast as f64).unwrap();
        cap.set(CAP_PROP_SATURATION, self.saturation as f64).unwrap();
        cap.set(CAP_PROP_GAIN, self.gain as f64).unwrap();
        cap.set(CAP_PROP_FRAME_WIDTH, self.frame_width as f64).unwrap();
        cap.set(CAP_PROP_FRAME_HEIGHT, self.frame_height as f64).unwrap();



        cap
    }

}

impl Default for CamSettings {

    fn default () -> Self {
        Self {
            auto_exposure: true,
            exposure: 157,
            brightness: 0,
            contrast: 32,
            saturation: 90,
            gain: 0,
            frame_width: 1280,
            frame_height: 720,
        }
    }
}


pub struct CamParameters {
    focal_length_x: i32,
    focal_length_y: i32,
    center_x: i32,
    center_y: i32,
    horizontal_angle: f32,
    vertical_angle: f32,
    angle_pixel_ratio: f32,
}
