#include "idt.h"
#include "../kernel.h"
#include "../config.h"
#include "../memory/memory.h"

struct idt_desc_entry idt[TOTAL_INTERRUPTS];
struct idtr_description idtr;

extern void idt_load(struct idtr_description* ptr);


void idt_zero(){
    print("\nIDT 35\n");
}

void idt_set(int interrupt_number, void* address) {
    struct idt_desc_entry* desc = &idt[interrupt_number];
    desc->offset_low = (uint32_t)address & 0xFFFF;
    desc->selector = KERNEL_CODE_SELECTOR;
    desc->zero = 0;
    desc->type_attr = 0x8E; // Interrupt gate, present, ring
    desc->offset_high = ((uint32_t)address >> 16);
}

void idt_init() {
    /* Initialize IDT entries to zero */
    mem_set(&idt, 0, sizeof(idt));

    /* Set up IDTR with the size and address of the IDT */
    idtr.limit = sizeof(idt) - 1;
    idtr.base = (uint32_t)idt;

    idt_set(0,idt_zero);
    
    idt_load(&idtr);
}
