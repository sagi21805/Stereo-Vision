use super::utils;
use opencv::core::*;
use opencv::prelude::VideoCaptureTrait;
use opencv::videoio::VideoCapture;
use std::rc::Rc;
use utils::camera::{CamParameters, CamSettings};

pub struct Camera<'a> {
    index: i32,
    cap: VideoCapture,
    settings: &'a CamSettings,
    params: &'a CamParameters,
    pub frame: Mat,
}

impl<'a> Camera<'a> {
    pub fn new(index: i32, settings: &'a CamSettings, params: &'a CamParameters) -> Self {
        let mut camera = Camera {
            index,
            cap: settings.initialize_cap(index).unwrap(),
            settings,
            params,
            frame: Mat::default()
        };

        camera.warm_up();

        return camera;
    }

    pub fn update_frame(&mut self) {
        self.cap.read(&mut self.frame).expect("Couldn't read frame");
    }

    fn warm_up(&mut self) {
        for _ in 0..30 {
            self.update_frame();
        }
    }
}
