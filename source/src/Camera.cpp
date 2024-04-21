#include "Camera.hpp"

Camera::Camera(uint32_t index, FOV fov, cv::Size_<uint16_t> frameSize, float32 focalLength) : 
    cam(cv::VideoCapture(index)), fov(fov), frameSize(frameSize), focalLength(focalLength), 
    angleToPixle_H(fov.horizontal / frameSize.width), angleToPixel_V(fov.vertical / frameSize.height) {}

bool Camera::getFrame(Mat outFrame) {
    return cam.read(outFrame);
}

FOV Camera::angleToCamera(Point point) {
    return FOV(point.x * angleToPixle_H, point.y * angleToPixel_V);
}

FOV Camera::getFov() {
    return this->fov; 
}

