#include "idt.h"
#include "../config.h"
#include "../memory/memory.h"
#include "../kernel.h"

//declare idt structure
struct idt_desc idt[TOTAL_INTERRUPTS];
struct idtr_desc idtr;

extern void load_idt(struct idtr_desc* idtr_ptr);

void idt_zero(){
    print("Zeroing IDT...\n");
}

void idt_set(int interrupt_number,void * address){
    struct idt_desc* desc = &idt[interrupt_number];
    desc->offset_1 = (uint32_t)address & 0x0000ffff;
    desc->selector = KERNEL_CODE_SEL;
    desc->type_attr = 0xEE;
    desc->zero = 0x00;
    desc->offset_2 = (uint32_t)address >> 16;
}

void idt_init(){

    print("Initializing IDT...\n");
    
    mem_set(idt,0, sizeof(idt));

    idtr.limit = sizeof(idt) - 1;
    idtr.base = (uint32_t)&idt;

    idt_set(0, idt_zero);

    load_idt(&idtr);

}