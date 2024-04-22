#ifndef _Util_
#define _Util_

#include <iostream>
#include <opencv4/opencv2/opencv.hpp>
#include <utility>
#include <cstdint>
#include <opencv4/opencv2/opencv.hpp>
#include <stdexcept>  

using cv::Mat;
typedef float float32;
typedef double float64;
typedef struct FOV FOV;
typedef cv::Point_<uint16_t> Point;
typedef cv::Size_<uint16_t> Size;

struct FOV {
    const float32 horizontal;
    const float32 vertical;

    FOV();

    FOV (float32 horizonatlAngle, float32 verticalAngle);

};

std::ostream& operator<<(std::ostream& os, FOV f);

float32 toRadians(float32 angle);

float32 toDegrees(float32 radian);

#endif

