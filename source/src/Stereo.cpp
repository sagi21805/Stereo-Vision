#include "Stereo.hpp"

float32 getDepth(Camera cam1, Camera cam2, Point point1, Point point2, float32 baseLine) {

    FOV angleFromCam1 = cam1.angleToCamera(point1);
    float32 angleFromCam2_H = cam2.angleToCamera(point2).horizontal;

    float32 angleA = M_PI_2 + (cam1.getFov().horizontal / 2) - angleFromCam1.horizontal; //In Radians
    float32 angleB = M_PI_2 - (cam2.getFov().horizontal / 2) + angleFromCam2_H; //In Radians
    float32 angleC = angleFromCam1.horizontal - angleFromCam2_H; //In Radians

    return (baseLine * sin(angleA) * sin(angleB)) / (sin(angleC) * cos(angleFromCam1.vertical)); //distance from the point between the cameras. 
    
}

uint32_t windowMSE(Mat img1, Mat img2, uint32_t windowSize, uint32_t imgRow, uint32_t imgCol) {        

    uchar* img1Data = img1.ptr();
    uchar* img2Data = img2.ptr();
    uint32_t MSE = 0;
    for (uint32_t windowRow = 0; windowRow < windowSize; windowRow++){
        for (uint32_t windowCol = 0; windowCol < windowSize; windowCol++){
            int16_t a = *(img1Data + windowCol + windowRow*img1.cols + imgCol*windowSize + imgRow*img1.cols*windowSize);
            int16_t b = *(img2Data + windowCol + windowRow*img2.cols + imgCol*windowSize + imgRow*img2.cols*windowSize);
            MSE += (a-b)*(a-b);
            
        }
    }
    return MSE;
}
