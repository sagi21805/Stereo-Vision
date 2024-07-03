#ifndef UTILS
#define UTILS

#include <stdio.h>
#include <stdint.h>
#include <malloc.h>
#include <time.h>
#include "simd.h"   

#define MEASURE_TIME(FCALL) ({ \
    double TOTAL = 0; \
    int REPEAT = 10; \
    for (int i = 0; i < REPEAT; i++) { \
        double START = clock(); \
        FCALL; \
        TOTAL += ((double) clock() - START) / CLOCKS_PER_SEC; \
    } \
    printf("time: %f\n", TOTAL / REPEAT);})

typedef struct {
    uint8_t* a;
    size_t size;
} Slice;


Slice createSlice(uint8_t *data, size_t size);

uint8_t* spaced_points(uint8_t num_of_points, uint8_t val);

uint8_t* generate_pointer_u8(uint8_t start, uint8_t stop);

uint16_t* generate_pointer_u16(uint16_t start, uint16_t stop);

uint32_t* generate_pointer_u32(uint32_t start, uint32_t stop);

uint32_t sum_uint8_arr(uint8_t* arr, size_t size);


static inline void print_int_ptr(const int32_t* p, size_t length){

    printf("[");
    for (int i = 0; i < length; i++){
        printf("%d ", p[i]);
    }
    printf("\b]\n");

}

static inline void print_uint8_ptr(const uint8_t* p, size_t length){

    printf("[");
    for (int i = 0; i < length; i++){
        printf("%d ", p[i]);
    }
    printf("\b]\n");

}

static inline void print_uint16_ptr(const uint16_t* p, size_t length){

    printf("[");
    for (int i = 0; i < length; i++){
        printf("%d ", p[i]);
    }
    printf("\b]\n");

}

static inline void print_uint32_ptr(const uint32_t* p, size_t length){

    printf("[");
    for (int i = 0; i < length; i++){
        printf("%d ", p[i]);
    }
    printf("\b]\n");

}


#endif