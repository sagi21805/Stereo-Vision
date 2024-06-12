use super::camera::Camera;
use opencv::prelude::*;


pub struct Stereo<'a> {

    cam1: Camera<'a>,
    cam2: Camera<'a>,
    base_line: f32,
    
}

impl<'a> Stereo<'a> {

    pub fn new(cam1: Camera<'a>, cam2: Camera<'a>, base_line: f32) -> Self {

        Stereo {
            cam1,
            cam2,
            base_line
        }

    }

    fn update_frame(&mut self) {
        self.cam1.update_frame();
        self.cam2.update_frame();
    }   

    fn write_frames(&self) {
        self.cam1.write_frames();
        self.cam2.write_frames();
    }
    
}