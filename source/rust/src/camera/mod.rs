pub mod cam_utils;
use opencv::prelude::VideoCaptureTrait;
use opencv::videoio::VideoCapture;
use opencv::imgcodecs::IMWRITE_PNG_COMPRESSION;
use cam_utils::{CamParameters, CamSettings};
use opencv::core::*;

pub struct Camera {

    index: i32,
    cap: VideoCapture,
    params: CamParameters,
    settings: CamSettings,
    pub frame: Mat
}

impl Camera {

    pub fn new(index: i32, settings: CamSettings, params: CamParameters) -> Self {

        Camera {
            index,
            cap: settings.initialize_cap(index).unwrap(),
            params,
            settings,
            frame: Mat::default()
        }

    }

    pub fn update_frame(&mut self) {

        self.cap.read(&mut self.frame).expect("Couldn't read frame");

    }

    pub fn write_frames(&self) {
        let mut params = Vector::new();
        params.push(IMWRITE_PNG_COMPRESSION);
        params.push(self.params.compersion_level); // Compression level (0-9, where 9 is the highest)
        opencv::imgcodecs::imwrite("test.png", &self.frame, &params).unwrap();
    }




}
