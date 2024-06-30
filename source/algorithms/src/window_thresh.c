#include <stdint.h>
#include <malloc.h>
#include <memory.h>
#include <arm_neon.h>


uint8_t* slidingWindowThresholdOptimized(
        uint8_t* img, int32_t rows, int32_t cols, int32_t window_size, uint8_t threshold
    ){
    
    const uint32_t movementRows = (rows - window_size) + 1;
    const uint32_t movementCols = (cols - window_size) + 1;
    
    const uint32_t thresh = threshold*window_size*window_size;
    uint32_t sum = 0;
    int32_t offset = 1-window_size; // second
    uint8_t* out = (uint8_t*) malloc(movementCols*movementRows); //sizeof(uin8_t is 1)
    memset(out, 0, movementCols*movementRows);

    for (uint32_t imgRow = 0; imgRow < movementRows; imgRow++){
        offset += window_size-1; //second
        for (uint32_t imgCol = 0; imgCol < movementCols; imgCol++){

            for (uint32_t windowRow = 0; windowRow < window_size; windowRow++){
                for (uint32_t windowCol = 0; windowCol < window_size; windowCol++){
                    sum += *(img + windowCol + windowRow*cols + imgCol + imgRow*cols + offset);
                }
            }
            if (sum > thresh){
                *(out + imgCol + imgRow*movementRows) = 255;
            }
            sum = 0;
        }
    }
    return out;
}

// void slidingWindowOptimized(Mat img, pair windowSize) {        
//     const uint32_t movementRows = (img.rows - windowSize.first) + 1;
//     const uint32_t movementCols = (img.cols - windowSize.second) + 1;
//     // cv::cvtColor(img, img, cv::COLOR_BGR2GRAY);
//     uchar* arr = img.ptr();
//     int32_t offset = 1-windowSize.second;
//     for (uint32_t imgRow = 0; imgRow < movementRows; imgRow++){
//         offset += windowSize.second-1;
//         for (uint32_t imgCol = 0; imgCol < movementCols; imgCol++){
//             std::cout << "\n";
//             for (uint32_t windowRow = 0; windowRow < windowSize.first; windowRow++){
//                 std::cout << "\n";
//                 for (uint32_t windowCol = 0; windowCol < windowSize.second; windowCol++){
//                     std::cout << (int) *(arr + windowCol + windowRow*img.cols + imgCol + imgRow*movementCols + offset)
//                     << " ";
//                 }
//             }
//         }
//     }
// }