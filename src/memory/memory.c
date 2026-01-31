#include "memory.h"

void* mem_set(void* dest, int c, size_t size){
    char* ptr = (char *)dest;
    for(int i = 0; i < size; i++){
        ptr[i] = (char)c;
    }
    return dest;
}