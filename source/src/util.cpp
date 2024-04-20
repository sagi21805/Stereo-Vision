#include "util.hpp"

float32 toRadians(float32 angle){
    return angle * M_PI / 180;
}

float32 toDegrees(float32 radian){
    return radian * 180 / M_PI;
}