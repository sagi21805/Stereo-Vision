#include "Util.hpp"

FOV::FOV() : horizontal(0), vertical(0) {}

FOV::FOV (float32 horizonatlAngle, float32 verticalAngle): 
    horizontal(horizonatlAngle), vertical(verticalAngle) {}

std::ostream& operator<<(std::ostream& os, FOV f){
    os << "horizontal: " << Utils::toDegrees(f.horizontal) << " vertical: " << Utils::toDegrees(f.vertical);
    return os;
}

float32 Utils::toRadians(float32 angle){
    return angle * M_PI / 180;
}

float32 Utils::toDegrees(float32 radian){
    return radian * 180 / M_PI;
}

void Utils::printWindow(Mat img, uint32_t windowSize, uint32_t imgRow, uint32_t imgCol) {
    uchar* imgData = img.ptr();
    for (uint32_t windowRow = 0; windowRow < windowSize; windowRow++){
        std::cout << "\n";
        for (uint32_t windowCol = 0; windowCol < windowSize; windowCol++){
            std::cout << (int) *(imgData + windowCol + windowRow*img.cols + imgCol*windowSize + imgRow*img.cols*windowSize) << " ";
        }
    }
    std::cout << "\n";
}


