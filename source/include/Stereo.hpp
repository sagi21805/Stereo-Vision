#ifndef _Stereo_
#define _Stereo_

#include "Util.hpp"
#include "Camera.hpp"

using pair = std::pair<uint16_t, uint16_t>;


float32 getDepth(Camera cam1, Camera cam2, Point point1, Point point2, float32 baseLine);

uint32_t windowMSE(Mat img1, Mat img2, uint32_t windowSize, uint32_t imgRow, uint32_t imgCol);
#endif