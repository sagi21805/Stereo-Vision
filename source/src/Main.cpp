#include "Stereo.hpp"


int main() {

    Camera cam(0, Size(2864, 1924), 2945.377);
    Camera cam1(1, Size(2864, 1924), 2945.377);

    Mat img1; cam.getFrame(img1);
    Mat img2; cam.getFrame(img2);

    uint8_t windowSize = 3;
    uint32_t totalNumOfWindows = (img1.cols / windowSize);



}