#ifndef _Camera_
#define _Camera_

#include "Util.hpp"
#include <vector>


typedef struct Camera Camera;

struct Camera {

    private: 
        cv::VideoCapture cam; 
        FOV fov; // In Radians
        Size frameSize; // In Pixels
        float32 focalLength; // In Pixels
        float32 angleToPixle_H;
        float32 angleToPixel_V;


    public: 

        Camera(uint32_t index, FOV fov, cv::Size_<uint16_t> frameSize, float32 focalLength);

        bool getFrame(Mat outFrame);

        FOV angleToCamera(Point point);

        FOV getFov();

};

#endif