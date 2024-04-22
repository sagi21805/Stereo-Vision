#include "Camera.hpp"

Camera::Camera(uint32_t index, Size frameSize, float32 focalLength) : 
    cam(cv::VideoCapture(index)), frameSize(frameSize), focalLength(focalLength), 
    fov(Camera::calcFov(frameSize, focalLength)), angleToPixle_H(fov.horizontal / frameSize.width), 
    angleToPixel_V(fov.vertical / frameSize.height)
    {}

Camera::Camera(uint32_t index, Size frameSize, FOV fov) :
    cam(cv::VideoCapture(index)), frameSize(frameSize), 
    focalLength(Camera::calcFocalLength(frameSize, fov)), 
    fov(fov), angleToPixle_H(fov.horizontal / frameSize.width), 
    angleToPixel_V(fov.vertical / frameSize.height)
    {}

float32 Camera::calcFocalLength(Size frameSize, FOV fov) {
    return frameSize.width / (2*tan(fov.horizontal/2));
}

FOV Camera::calcFov(Size frameSize, float32 focalLength){
    return FOV(2*atan(frameSize.width / (2*focalLength)), 2*atan(frameSize.height / (2*focalLength)));
}

bool Camera::getFrame(Mat outFrame) {
    return cam.read(outFrame);
}

FOV Camera::angleToCamera(Point point) {
    return FOV(point.x * angleToPixle_H, point.y * angleToPixel_V);
}

FOV Camera::getFov() {
    return this->fov; 
}

float32 Camera::getFocalLegth() {
    return this->focalLength;
}


