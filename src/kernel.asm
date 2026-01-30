[BITS 32]
global _start
global problem
extern kernel_main
CODE_SEG EQU 0x08
DATA_SEG EQU 0x10

_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ;enable a20 line using fast a20 gate
    in al, 0x92
    or al, 2
    out 0x92, al
    call kernel_main   
    jmp $

problem:
    mov eax, 0
    div eax

times 512-($-$$) db 0
