pub mod cam_utils;
use std::rc::Rc;
use super::utils;
use opencv::prelude::VideoCaptureTrait;
use opencv::videoio::VideoCapture;
use cam_utils::{CamParameters, CamSettings};
use opencv::core::*;

pub struct Camera<'a> {

    index: i32,
    cap: VideoCapture,
    params: CamParameters,
    settings: CamSettings,
    pub frame: Mat,
    pub frame_slice: Option<Rc<&'a [u8]>>
}

impl<'a> Camera<'a> {

    pub fn new(index: i32, settings: CamSettings, params: CamParameters) -> Self {

        Camera {
            index,
            cap: settings.initialize_cap(index).unwrap(),
            params,
            settings,
            frame: Mat::default(),
            frame_slice: None
        }

    }

    pub fn update_frame(&mut self) {

        self.cap.read(&mut self.frame).expect("Couldn't read frame");
        self.frame_slice = utils::mat_to_slice(&self.frame);

    }

    pub fn write_frames(&self) {
        opencv::imgcodecs::imwrite(
            "test.png", &self.frame, &self.params.png_params
        ).unwrap();
    }




}
