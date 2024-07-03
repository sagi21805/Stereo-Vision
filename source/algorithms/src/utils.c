#include "utils.h"

Slice createSlice(uint8_t *data, size_t size) {
    Slice slice;
    slice.a = data;
    slice.size = size;
    return slice;
}

uint8_t* spaced_points(uint8_t num_of_points, uint8_t val){
    
    uint8_t* points = (uint8_t*) malloc(num_of_points);
    
    points[0] = 0;
    uint8_t step = val / (num_of_points - 1);

    for (int i = 1; i < num_of_points; i++) {

        points[i] = points[i - 1] + step;
    
    }

    return points;

}

uint8_t* generate_pointer_u8(uint8_t start, uint8_t stop) {

    uint8_t size = (stop - start);

    uint8_t *ptr = (uint8_t *)malloc(size * sizeof(uint8_t));

    if (ptr == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL;
    }

    for (uint8_t i = 0, value = start; i < size; ++i, value++) {
        ptr[i] = (uint8_t)value;
    }

    return ptr;
}

uint16_t* generate_pointer_u16(uint16_t start, uint16_t stop) {

    uint16_t size = (stop - start);

    uint16_t *ptr = (uint16_t *)malloc(size * sizeof(uint16_t));

    if (ptr == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL;
    }

    for (uint16_t i = 0, value = start; i < size; ++i, value++) {
        ptr[i] = (uint16_t)value;
    }

    return ptr;
}

uint32_t* generate_pointer_u32(uint32_t start, uint32_t stop) {

    uint32_t size = (stop - start);

    uint32_t *ptr = (uint32_t *)malloc(size * sizeof(uint32_t));

    if (ptr == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL;
    }

    for (uint32_t i = 0, value = start; i < size; ++i, value++) {
        ptr[i] = (uint32_t)value;
    }

    return ptr;
}

uint32_t sum_uint8_arr(uint8_t* arr, size_t size){

    uint32_t sum = 0;
    size_t left_size = size/2;
    size_t right_size = size - left_size;

    while (left_size != 1) {

        uint16_t temp[left_size];

        add_arrays_u8_u8_u16(arr, arr + left_size, temp, left_size);

        if (left_size < right_size) {
            sum += arr[size - 1];
        } 

        size_t new_size = left_size;

        left_size = new_size/2;
        right_size = new_size - left_size;

    }

    

}