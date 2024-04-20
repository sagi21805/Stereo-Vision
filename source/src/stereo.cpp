#include "stereo.hpp"

float32 getDepth(float32 camFOV, float32 baseLine, float32 angleFromCam1, float32 angleFromCam2, float32 horizontalAngle) {

    float32 angleA = M_PI_2 + (camFOV / 2) - angleFromCam1; //In Radians
    float32 angleB = M_PI_2 - (camFOV / 2) + angleFromCam2; //In Radians
    float32 angleC = angleFromCam1 - angleFromCam2; //In Radians

    return ((baseLine * sin(angleA) * sin(angleB)) / sin(angleC)) / sin(horizontalAngle); //distance from the point between the cameras. 
    
}


// int main() {

//     uint16_t x = 3;
//     float32 a = 3.25;

//     float32 b = a / x;

//     std::cout << "b: " << b << "\n";
// }