use opencv::prelude::*;
use opencv::videoio::{VideoCapture, VideoWriter,
    CAP_ANY, CAP_PROP_EXPOSURE, CAP_PROP_BRIGHTNESS, CAP_PROP_CONTRAST, CAP_PROP_AUTO_EXPOSURE,
    CAP_PROP_SATURATION, CAP_PROP_GAIN, CAP_PROP_FRAME_WIDTH, CAP_PROP_FRAME_HEIGHT, CAP_PROP_FOURCC};

pub struct CamSettings {
    pub auto_exposure: bool,
    pub exposure: i32,
    pub brightness: i32,
    pub contrast: i32,
    pub saturation: i32,
    pub gain: i32,
    pub frame_width: i32,
    pub frame_height: i32,
}

impl CamSettings {

    pub fn initialize_cap(&self, index: i32) -> Result<VideoCapture, &str> {
        let mut cap = VideoCapture::new(index, CAP_ANY).unwrap(); 

        if !VideoCapture::is_opened(&cap).unwrap() {
            return Err("Couldn't open cam");
        }

        let fourcc = VideoWriter::fourcc('M', 'J', 'P', 'G').unwrap() as f64;
        cap.set(CAP_PROP_FOURCC, fourcc).unwrap();
        cap.set(CAP_PROP_AUTO_EXPOSURE, (3 - (!self.auto_exposure as i32 * 2)) as f64).unwrap();
        cap.set(CAP_PROP_EXPOSURE, self.exposure as f64).unwrap();
        cap.set(CAP_PROP_BRIGHTNESS, self.brightness as f64).unwrap();
        cap.set(CAP_PROP_CONTRAST, self.contrast as f64).unwrap();
        cap.set(CAP_PROP_SATURATION, self.saturation as f64).unwrap();
        cap.set(CAP_PROP_GAIN, self.gain as f64).unwrap();
        cap.set(CAP_PROP_FRAME_WIDTH, self.frame_width as f64).unwrap();
        cap.set(CAP_PROP_FRAME_HEIGHT, self.frame_height as f64).unwrap();



        Ok(cap)
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
    pub focal_length_x: i32,
    pub focal_length_y: i32,
    pub center_x: i32,
    pub center_y: i32,
    pub horizontal_angle: f32,
    pub vertical_angle: f32,
    pub angle_pixel_ratio: f32,
    pub compersion_level: i32
}

impl CamParameters {


    pub fn empty() -> Self {

        CamParameters {
            focal_length_x: -1,
            focal_length_y: -1,
            center_x: -1,
            center_y: -1,
            horizontal_angle: -1.0,
            vertical_angle: -1.0,
            angle_pixel_ratio: -1.0,
            compersion_level: 9
        }

    }

}
