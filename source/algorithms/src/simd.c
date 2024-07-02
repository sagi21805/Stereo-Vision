#include "simd.h"

#define SIMD_SIZE 128
#define SIMD_SIZE_BYTE SIMD_SIZE / 8

void add_arrays_u8_u8_u16(const uint8_t* a, const uint8_t* b, uint16_t* c, size_t size) {

    size_t i = 0;
    size_t step_size = SIMD_SIZE_BYTE / sizeof(uint16_t);

    for (; i < (size - step_size); i += step_size) {
        // Load 8 uint8_t elements from array1 and array2
        uint8x8_t neon1 = vld1_u8(a + i);
        uint8x8_t neon2 = vld1_u8(b + i);

        // Convert uint8_t to uint16_t by zero-extending and then add
        uint16x8_t sum = vaddl_u8(neon1, neon2);

        // Store the result in result array as uint16_t
        vst1q_u16(c + i, sum);
    }

    for (; i < size; i++){
        c[i] = (uint16_t) a[i] + b[i];
    }
    
}

void add_arrays_u16_u16_u16(const uint16_t* a, const uint16_t* b, uint16_t* c, size_t size) {

    size_t i = 0;
    size_t step_size = SIMD_SIZE_BYTE / sizeof(uint16_t);

    for (; i < (size - step_size); i += step_size) {
        // Load 8 uint8_t elements from array1 and array2
        uint16x8_t neon1 = vld1q_u16(a + i);
        uint16x8_t neon2 = vld1q_u16(b + i);

        // Convert uint8_t to uint16_t by zero-extending and then add
        uint16x8_t sum = vaddq_u16(neon1, neon2);

        // Store the result in result array as uint16_t
        vst1q_u16(c + i, sum);
    }

    for (; i < size; i++){
        c[i] = a[i] + b[i];
    }
    
}

void add_arrays_u16_u16_u32(const uint16_t* a, const uint16_t* b, uint32_t* c, size_t size) {

    size_t i = 0;
    size_t step_size = SIMD_SIZE_BYTE / sizeof(uint32_t);

    for (; i < (size - step_size); i += step_size) {
        // Load 8 uint8_t elements from array1 and array2
        uint16x4_t neon1 = vld1_u16(a + i);
        uint16x4_t neon2 = vld1_u16(b + i);

        // Convert uint8_t to uint16_t by zero-extending and then add
        uint32x4_t sum = vaddl_u16(neon1, neon2);

        // Store the result in result array as uint16_t
        vst1q_u32(c + i, sum);
    }

    for (; i < size; i++){
        c[i] = (uint32_t) a[i] + b[i];
    }
    
}

