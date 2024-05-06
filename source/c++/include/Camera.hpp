#ifndef _Camera_
#define _Camera_

#include "Util.hpp"
#include <vector>


typedef struct Camera Camera;

struct Camera {

    public: 
        cv::VideoCapture cam; 
        Size frameSize; // In Pixels
        float32 focalLength; // In Pixels
        FOV fov; // In Radians
        float32 angleToPixle_H;
        float32 angleToPixel_V;

        static float32 calcFocalLength(Size frameSize, FOV fov);

        static FOV calcFov(Size frameSize, float32 focalLength);

    public: 

        Camera() = default;

        Camera(uint32_t index, Size frameSize, float32 focalLength);
        
        Camera(uint32_t index, Size frameSize, FOV fov);

        Camera(Size frameSize, float32 focalLength);

        bool getFrame(Mat outFrame);

        FOV angleToCamera(Pose2d windowPose);
        
        float32 getFocalLegth();

        FOV getFov();

};

#endif