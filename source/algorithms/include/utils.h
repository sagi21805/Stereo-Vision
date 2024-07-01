#ifndef UTILS
#define UTILS

#include "stdio.h"
#include "stdint.h"



static inline void print_int_ptr(int* p, int length){

    printf("[");
    for (int i = 0; i < length; i++){
        printf("%d ", p[i]);
    }
    printf("\b]\n");

}

static inline void print_uint8_ptr(uint8_t* p, int length){

    printf("[");
    for (int i = 0; i < length; i++){
        printf("%d ", p[i]);
    }
    printf("\b]\n");

}

static inline void print_uint16_ptr(uint16_t* p, int length){

    printf("[");
    for (int i = 0; i < length; i++){
        printf("%d ", p[i]);
    }
    printf("\b]\n");

}

#endif