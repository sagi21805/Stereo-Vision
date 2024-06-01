use super::cam_utils::CamSettings;
use opencv::videoio::{VideoCapture, VideoWriter};
use super::cam_utils::CamParameters;

pub struct Camera {

    index: i32,
    cap: VideoCapture,
    parameters: CamParameters,
    settings: CamSettings,
}

impl Camera {

    pub fn new(index: i32, settings: CamSettings, parameters: CamParameters) -> Self {

        Camera {
            index: index,
            cap: settings.initialize_cap(index),
            parameters: parameters,
            settings: settings,
        }

    }

}
