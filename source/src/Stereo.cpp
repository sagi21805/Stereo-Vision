#include "stereo.hpp"

float32 getDepth(Camera cam1, Camera cam2, Point point1, Point point2, float32 baseLine) {

    FOV angleFromCam1 = cam1.angleToCamera(point1);
    float32 angleFromCam2_H = cam2.angleToCamera(point2).horizontal;

    float32 angleA = M_PI_2 + (cam1.getFov().horizontal / 2) - angleFromCam1.horizontal; //In Radians
    float32 angleB = M_PI_2 - (cam2.getFov().horizontal / 2) + angleFromCam2_H; //In Radians
    float32 angleC = angleFromCam1.horizontal - angleFromCam2_H; //In Radians

    return (baseLine * sin(angleA) * sin(angleB)) / (sin(angleC) * cos(angleFromCam1.vertical)); //distance from the point between the cameras. 
    
}


// int main() {

//     uint16_t x = 3;
//     float32 a = 3.25;

//     float32 b = a / x;

//     std::cout << "b: " << b << "\n";
// }