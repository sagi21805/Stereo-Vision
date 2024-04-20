#include "util.hpp"

typedef struct Camera Camera;

struct Camera {

    private: 
        cv::VideoCapture cam; 
        FOV fov; // In Radians
        cv::Size_<uint16_t> frameSize; // In Pixels
        float32 focalLength; // In Pixels
        float32 angleToPixle_H;
        float32 angleToPixel_V;

    public: 

        Camera(uint32_t index, FOV fov, cv::Size_<uint16_t> frameSize, float32 focalLength) : 
            cam(cv::VideoCapture(index)), fov(fov), frameSize(frameSize), focalLength(focalLength), 
            angleToPixle_H(fov.horizontal / frameSize.width), angleToPixel_V(fov.vertical / frameSize.height) {}

        bool getFrame(Mat outFrame) {
            return cam.read(outFrame);
        }

        float32 angleToCamera(uint16_t);

};