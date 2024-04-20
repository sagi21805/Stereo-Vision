#include <iostream>
#include <opencv4/opencv2/opencv.hpp>

using cv::Mat;
typedef float float32;
typedef double float64;
typedef struct FOV FOV;
typedef cv::Point_<uint16_t> Point;
typedef cv::Size_<uint16_t> Size;

struct FOV {
    const float32 horizontal;
    const float32 vertical;

    FOV() : horizontal(0), vertical(0) {}

    FOV (float32 horizonatlAngle, float32 verticalAngle): 
        horizontal(horizonatlAngle), vertical(verticalAngle) {}
};

float32 toRadians(float32 angle);
float32 toDegrees(float32 radian);

