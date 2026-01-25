ORG 0x7c00
BITS 16

HEIGHT EQU 25
WIDTH  EQU 80


start:
    call create_window
    call set_cursor_position
    cli
    hlt

set_cursor_position:
    mov ah, 02h     ; BIOS function: Set Cursor Position
    mov bh, 0       ; Page number
    mov dh, 0       ; Row
    mov dl, 0       ; Column
    int 0x10
    ret

create_window:
    ;init a window of 80x25 at position 0,0
    mov cl, 0 ;row
    call .print_window
    
.print_window:
    cmp cl, HEIGHT
    jge .done_rows

    mov ah, 02h     ; BIOS function: Set Cursor Position
    mov bh, 0       ; Page number
    mov dh, cl      ; Row
    mov dl, 0       ; Column (start at 0)
    int 0x10
    
    call .print_row
    inc cl
    jmp .print_window

.done_rows:
    ret
.print_row:
    mov ah, 09h
    mov al, ' '
    mov bl, 0F0h ; black on white background (white box)
    mov dl, cl
    mov cx, WIDTH
    int 0x10
    mov cl,dl
    mov dh, 0
    ret

times 510-($-$$) db 0
dw 0xaa55

    