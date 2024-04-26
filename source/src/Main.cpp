#include "Stereo.hpp"

void test() {

    uchar testArray[] {
     0,  1,  2,  3,  4,  5,  6,  7,  8,  9,
     10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
     20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
     30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
     40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
     50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
     60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
     70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 
     80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 
     90, 91, 92, 93, 94, 95, 96, 97, 98, 99
    };

    cv::Mat A(10,10,CV_8U);
    std::memcpy(A.data, testArray, 10*10*sizeof(uchar));
    printWindow(A, 3, 0, 1);

}

int main() {

    Camera cam(0, Size(2864, 1924), 2945.377);
    Camera cam1(1, Size(2864, 1924), 2945.377);

    Mat img1; cam.getFrame(img1);
    Mat img2; cam.getFrame(img2);

    uint8_t windowSize = 3;
    uint32_t windowsPerCol = (img1.cols / windowSize);
    uint32_t windowsPerRow = (img1.rows / windowSize);

    std::vector<bool> canMatchWindow(windowsPerRow*windowsPerCol, true); 
    
    for (uint32_t imgRow = 0; imgRow < img1.rows; imgRow++) {

        for (uint32_t currentCol = 0; currentCol < windowsPerCol; currentCol++) {

            Pose2d currentWindowPose(imgRow, currentCol);
            uint32_t error = UINT32_MAX;
            Pose2d matchingWindowPose(UINT16_MAX, UINT16_MAX);
            //write this max in a more std lib way.
            for (uint32_t matchedCol = 0; matchedCol < windowsPerCol; matchedCol++) {

                Pose2d matchedWindowPose(imgRow, matchedCol);

                uint32_t currentError = windowMSE(img1, img2, windowSize, currentWindowPose, matchedWindowPose); 

                if (currentError < error && canMatchWindow[matchedCol + imgRow*windowsPerCol]) {
                    error  = currentError;
                    matchingWindowPose = matchedWindowPose;
                }
            }

            if (error < UINT32_MAX) {
                canMatchWindow[matchingWindowPose.col + matchingWindowPose.row * windowsPerCol] = false;
                // currentWindowPose and matchingWindow are matching
                // create a calc distance for them and set it in the depth map
            }

        }

    }


}