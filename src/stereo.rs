use super::{
    camera::Camera,
    utils,
    utils::camera::{CamParameters, CamSettings},
};
use crate::pub_struct;

pub_struct! {
    pub struct Stereo<'a> {

        cam1: Camera<'a>,
        cam2: Camera<'a>,
        base_line: f32,

    }

}

impl<'a> Stereo<'a> {
    pub fn new(
        index1: i32,
        index2: i32,
        base_line: f32,
        settings: &'a CamSettings,
        params: &'a CamParameters,
    ) -> Self {
        Stereo {
            cam1: Camera::new(index1, settings, params),
            cam2: Camera::new(index2, settings, params),
            base_line,
        }
    }

    pub fn update_frame(&mut self) {
        self.cam1.update_frame();
        self.cam2.update_frame();
    }

    pub fn save_frame(&self) {
        utils::save_frame("Cam1", &self.cam1.frame);
        utils::save_frame("Cam2", &self.cam2.frame);
    }
}
