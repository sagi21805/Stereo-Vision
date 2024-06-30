#ifndef WINDOW_THRESH
#define WINDOW_THRESH

#include <stdint.h>
#include <malloc.h>
#include <memory.h>


uint8_t* slidingWindowThresholdOptimized(
        uint8_t* img, int32_t rows, int32_t cols, int32_t window_size, uint8_t threshold
    );

#endif