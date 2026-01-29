#include "kernel.h"
#include <stdint.h>

uint8_t *video_memory = (uint8_t *)0xb8000;

void print_message(){
    char message[] = "Hello! world";
    int strlen = sizeof(message)/sizeof(message[0]);
    for(int i = 0; i < strlen; i++){
        video_memory[i * 2] = message[i];
        video_memory[i * 2 + 1] = 0x06; // Light grey on black background
    }
}

void kernel_main(){
    print_message();
    while(1);  

}