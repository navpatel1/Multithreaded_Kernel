#include "kernel.h"
#include <stdint.h>
#include <stddef.h>
#include "idt/idt.h"

uint16_t *video_memory = 0;
uint16_t terminal_row = 0;
uint16_t terminal_column = 0;

//(x = row, y = column)

uint16_t terminal_make_char(char c, uint8_t color)
{
    return (uint16_t)c | (uint16_t)color << 8;
}

void terminal_putchar(char c, uint8_t color, size_t x, size_t y)
{
    video_memory[x * VGA_WIDTH + y] = terminal_make_char(c, color);
}

void terminal_writechar(char c, uint8_t color)
{
    if(c == '\n') {
      terminal_column = 0;
      terminal_row++;
      return;
    }
    terminal_putchar(c, color, terminal_row, terminal_column);
    terminal_column++;
    if(terminal_column >= VGA_WIDTH){
        terminal_column = 0;
        terminal_row++;
    }
}

void terminal_initialize()
{
    video_memory = (uint16_t*)0xB8000;
    terminal_row = 0;
    terminal_column = 0;
    for(int x = 0; x < VGA_HEIGHT; x++){
        for(int y = 0; y < VGA_WIDTH; y++){
            terminal_putchar(' ', 0x0, x, y);
        }
    }
}

size_t strlen(const char* str){
    size_t len = 0;
    while(str[len] != '\0'){
        len++;
    }
    return len;
}

void print(const char* str){
    size_t len = strlen(str);
    for(size_t i = 0; i < len; i++){
        terminal_writechar(str[i], 15);
    }
}

extern void problem(void);

void kernel_main(){

    terminal_initialize();
    print("Hello, Kernel World!\nAdded new line support.\nC17 standard in use.\n");

    idt_init();

    problem(); // Removed - this function

}