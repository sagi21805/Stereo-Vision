// #include "simd.h"
// #include "utils.h"
#include <omp.h>
#include <time.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <arm_neon.h>
#include <stdio.h>
// #include <assert.h>

void add_uint8_simd(uint8_t* a, uint8_t* b, uint8_t* result, int size) {
    int i;
    int num_chunks = size / 16; // Assuming size is a multiple of 16 for 128-bit SIMD

    // Load data into NEON registers
    uint8x16_t va, vb, vresult;
    for (i = 0; i < num_chunks; ++i) {
        va = vld1q_u8(a);
        vb = vld1q_u8(b);
        
        // Perform SIMD addition
        vresult = vaddq_u8(va, vb);

        // Store result back to memory
        vst1q_u8(result, vresult);

        // Move pointers to next chunk
        a += 16;
        b += 16;
        result += 16;
    }
}

int main() {
    const int size = 64; // Example size
    uint8_t a[size], b[size], result[size];

    // Initialize arrays a and b with some values (example)
    for (int i = 0; i < size; ++i) {
        a[i] = i;
        b[i] = size - i;
    }

    // Call SIMD addition function
    add_uint8_simd(a, b, result, size);

    // Print the result (example)
    printf("[");
    for (int i = 0; i < size; ++i) {
        printf("%d ", result[i]);
    }
    printf("\b]\n");

    return 0;
}