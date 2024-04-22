#include "Util.hpp"

FOV::FOV() : horizontal(0), vertical(0) {}

FOV::FOV (float32 horizonatlAngle, float32 verticalAngle): 
    horizontal(horizonatlAngle), vertical(verticalAngle) {}

std::ostream& operator<<(std::ostream& os, FOV f){
    os << "horizontal: " << toDegrees(f.horizontal) << " vertical: " << toDegrees(f.vertical);
    return os;
}

float32 toRadians(float32 angle){
    return angle * M_PI / 180;
}

float32 toDegrees(float32 radian){
    return radian * 180 / M_PI;
}

