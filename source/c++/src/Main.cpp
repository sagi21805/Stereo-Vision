#include "Stereo.hpp"
#include <chrono>
using namespace std::chrono;
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
    Utils::printWindow(A, 3, 0, 1);

}

int main() {
    auto start = high_resolution_clock::now();

    Camera cam1(0, Size(2864, 1924), 2945.377);
    Camera cam2(1, Size(2864, 1924), 2945.377);
    float32 baseLine = 178.232; //mm
    uint8_t windowSize = 2;
    Stereo stereo(cam1, cam2, baseLine, windowSize);

    std::cout << "angle to pixel: " << cam1.angleToPixle_H << "\n";

    cv::cvtColor(stereo.frame1, stereo.frame1, cv::COLOR_BGR2GRAY);
    cv::cvtColor(stereo.frame2, stereo.frame2, cv::COLOR_BGR2GRAY);
    Utils::printWindow(stereo.frame1, 2, 0, 0);

    float32 depthMap[stereo.windowsPerCol*stereo.windowsPerRow];
    for (uint32_t imgRow = 0; imgRow < stereo.windowsPerRow; imgRow++) {

        for (uint32_t currentCol = 0; currentCol < stereo.windowsPerCol; currentCol++) {

            Pose2d currentWindowPose(imgRow, currentCol);
            Pose2d matchingWindowPose = stereo.matchingWindowPosition(currentWindowPose);
            
            float32 depth = stereo.getDepth(currentWindowPose, matchingWindowPose);

          
            *(depthMap + currentCol + imgRow * stereo.windowsPerCol) = depth;

                // TODO currentWindowPose and matchingWindow are matching
                // TODO create a calc distance for them and set it in the depth map
        }
    }

    stereo.canMatchWindow = std::vector<bool>(stereo.windowsPerCol*stereo.windowsPerRow, true);
    Mat map(stereo.windowsPerRow, stereo.windowsPerCol, CV_32F);
    map.data = (uchar*) depthMap;
    // Mat img;
    // cv::resize(stereo.frame1, img, cv::Size(stereo.windowsPerCol, stereo.windowsPerRow));
    // cv::imshow("img", img);
    // cv::imshow("map", map);
    // cv::waitKey(0);
    for (int i = 0; i < 10; i++){
        std::cout << depthMap[i] << "\n";
    }
    cv::imwrite("test.png", map);
    std::cout << depthMap[0] << "\n";
    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<nanoseconds>(stop - start);
    std::cout << duration.count() / 1000000000.0 << "\n";


}