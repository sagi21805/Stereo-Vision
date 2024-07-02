#ifndef SIMD
#define SIMD

#include <arm_neon.h>
#include <stdint.h>
#include <malloc.h>
#include <memory.h>
#include <math.h>

void add_arrays_u8_u8_u16(const uint8_t* a, const uint8_t* b, uint16_t* c, size_t size);

void add_arrays_u16_u16_u16(const uint16_t* a, const uint16_t* b, uint16_t* c, size_t size);

void add_arrays_u16_u16_u32(const uint16_t* a, const uint16_t* b, uint32_t* c, size_t size);

#endif