ORG 0x7c00
BITS 16

start:
    mov si, msg
    mov bx,0

print_loop:
    lodsb
    cmp al, 0
    je done
    call print_char
    jmp print_loop

print_char:
    mov ah, 0x0E
    int 0x10
    ret

done:
    cli
    hlt

msg db 'Hello, World!',0

times 510-($-$$) db 0
dw 0xaa55

    