#ifndef WINDOW_THRESH
#define WINDOW_THRESH

#include <stdint.h>
#include <malloc.h>
#include <memory.h>

#ifdef __cplusplus
extern "C" {
#endif

uint8_t* slidingWindowThreshold(
        uint8_t* img, int32_t rows, int32_t cols, uint32_t window_size, uint8_t threshold
);

uint8_t* slidingWindowMultiThreshold(
        uint8_t* img, int32_t rows, int32_t cols, uint32_t window_size, uint8_t thresholds_num
);

#ifdef __cplusplus
}
#endif

#endif