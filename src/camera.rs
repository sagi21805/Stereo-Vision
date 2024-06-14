use super::utils;
use std::rc::Rc;
use opencv::prelude::VideoCaptureTrait;
use opencv::videoio::VideoCapture;
use utils::camera::{CamParameters, CamSettings};
use opencv::core::*;

pub struct Camera<'a> {

    index: i32,
    cap: VideoCapture,
    settings: &'a CamSettings,
    params: &'a CamParameters,
    pub frame: Mat,
    pub frame_slice: Option<Rc<&'a [u8]>>,
}

impl<'a> Camera<'a> {

    pub fn new(index: i32, settings: &'a CamSettings, params: &'a CamParameters) -> Self {

        let mut camera = Camera {
            index,
            cap: settings.initialize_cap(index).unwrap(),
            settings,
            params,
            frame: Mat::default(),
            frame_slice: None,
        }; 

        camera.warm_up();
        
        return camera;
    }

    
    pub fn update_frame(&mut self) {
        
        self.cap.read(&mut self.frame).expect("Couldn't read frame");
        self.frame_slice = utils::mat_to_slice(&self.frame);
        
    }
        
    fn warm_up(&mut self) {

        for _ in 0..20 {   
            self.cap.read(&mut self.frame).expect("Couldn't read frame");
        }
    }
        
        
        
        
        }
        