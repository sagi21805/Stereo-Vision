use super::camera::Camera;
use opencv::prelude::*;


struct Stereo {

    cam1: Camera,
    cam2: Camera,
    base_line: f32,
    
}

impl Stereo {

    fn new(cam1: Camera, cam2: Camera, base_line: f32) -> Self {

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