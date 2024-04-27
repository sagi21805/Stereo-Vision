#ifndef _Stereo_
#define _Stereo_

#include "Util.hpp"
#include "Camera.hpp"
#include <algorithm>


using pair = std::pair<uint16_t, uint16_t>;

class Stereo {

    public:
        Camera cam1;
        Camera cam2; 
        float32 baseLine;
        uint8_t windowSize; 
        Mat frame1;
        Mat frame2;
        uint32_t windowsPerCol;
        uint32_t windowsPerRow;
        std::vector<bool> canMatchWindow; 

    Stereo() = default;

    Stereo(Camera cam1, Camera cam2, float32 baseLine, uint8_t windowSize);

    float32 getDepth(Point point1, Point point2, float32 baseLine);

    uint32_t windowMSE(uint32_t windowSize, Pose2d pose1, Pose2d pose2);

    Pose2d matchingWindowPosition(Pose2d matchedWindowPose);
};

#endif