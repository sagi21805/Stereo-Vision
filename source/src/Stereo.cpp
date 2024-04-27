#include "Stereo.hpp"

Stereo::Stereo(Camera cam1, Camera cam2, float32 baseLine, uint8_t windowSize) 
    : cam1(cam1), cam2(cam2), baseLine(baseLine), windowSize(windowSize) {
        cam1.getFrame(frame1);        
        cam2.getFrame(frame2);
        // frame1 = cv::imread("data/im0-min.jpeg"); //TODO create a way for dummy stereo
        // frame2 = cv::imread("data/im1-min.jpeg");
        //TODO make a check that frame one is in the same shape as frame2;
        windowsPerRow = frame1.rows / windowSize;
        windowsPerCol = frame1.cols / windowSize;
        canMatchWindow = std::vector<bool>(windowsPerRow*windowsPerCol, true); 
    }

float32 Stereo::getDepth(Pose2d firstWindowPose, Pose2d secondWindowPose) {

    FOV angleFromCam1 = cam1.angleToCamera(firstWindowPose);
    float32 angleFromCam2_H = cam2.angleToCamera(secondWindowPose).horizontal;

    float32 angleA = M_PI_2 + (cam1.getFov().horizontal / 2) - angleFromCam1.horizontal; //In Radians
    float32 angleB = M_PI_2 - (cam2.getFov().horizontal / 2) + angleFromCam2_H; //In Radians
    float32 angleC = angleFromCam1.horizontal - angleFromCam2_H; //In Radians

    return (baseLine * sin(angleA) * sin(angleB)) / (sin(angleC) * cos(angleFromCam1.vertical)); //distance from the point between the cameras. 
    
}

uint32_t Stereo::windowMSE(uint32_t windowSize, Pose2d pose1, Pose2d pose2) {        

    uchar* frame1Data = frame1.ptr();
    uchar* frame2Data = frame2.ptr();
    uint32_t MSE = 0;
    for (uint32_t windowRow = 0; windowRow < windowSize; windowRow++){
        for (uint32_t windowCol = 0; windowCol < windowSize; windowCol++){
            int16_t a = *(frame1Data + windowCol + windowRow*frame1.cols + pose1.col*windowSize + pose1.row*frame1.cols*windowSize);
            int16_t b = *(frame2Data + windowCol + windowRow*frame2.cols + pose2.col*windowSize + pose2.row*frame2.cols*windowSize);
            MSE += (a-b)*(a-b);
            
        }
    }
    return MSE;
}

Pose2d Stereo::matchingWindowPosition(Pose2d matchedWindowPose) {

    uint32_t matchingCol = UINT32_MAX;
    uint32_t error = UINT32_MAX;

    for (uint32_t startCol = 0; startCol < windowsPerCol; startCol++) {
        uint32_t currentErr = windowMSE(windowSize, matchedWindowPose, Pose2d(matchedWindowPose.row, startCol));  
        if (currentErr < error && canMatchWindow[startCol + matchedWindowPose.row*windowsPerCol]) {   
            error = currentErr;
            matchingCol = startCol;
        }
    }
    canMatchWindow[matchingCol + matchedWindowPose.row*windowsPerCol] = false;
    
    return Pose2d(matchedWindowPose.row, matchingCol);

}