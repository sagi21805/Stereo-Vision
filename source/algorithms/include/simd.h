#ifndef SIMD
#define SIMD

#include <arm_neon.h>
#include <stdio.h>
#include <time.h>
#include "utils.h"

void add_uint8_simd(const uint8_t* a, const uint8_t* b, uint16_t* res, size_t len);


#endif