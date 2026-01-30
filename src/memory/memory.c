#include "memory.h"

void* mem_set(void* dest,int val,size_t size){
    unsigned char* ptr = (unsigned char*)dest;
    for(size_t i = 0; i < size; i++){
        ptr[i] = (unsigned char)val;
    }
    return dest;
}