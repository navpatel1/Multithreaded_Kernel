ORG 0x0
BITS 16

HEIGHT EQU 25
WIDTH  EQU 80

jmp 0x7c0:start ;it sets our code segment to 0x7c0 and offset becomes start

start:
    cli
    mov ax,0x7c0     
    mov ds,ax    ;setting our data segment to 0x7c0 so DS:SI should work properly
    mov es,ax
    mov ax, 0x00
    mov ss, ax   ;setting up stack segment to zero is still questionable 
    mov sp, 0x7c00 ;stack pointer is correct because we have bios datat area below 0x7c00
    sti
    call create_window
    call set_cursor_position
    call print_msg
    cli
    hlt

set_cursor_position:
    mov ah, 02h     ; BIOS function: Set Cursor Position
    mov bh, 0       ; Page number
    mov dh, 0       ; Row
    mov dl, 1       ; Column
    int 0x10
    ret

print_msg:
    mov si, msg
.print_char:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0Eh     ; BIOS function: Teletype Output
    mov bh, 0       ; Page number
    int 0x10
    jmp .print_char
.done:
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

msg db 'Welcome to My kernel OS!',0
times 510-($-$$) db 0
dw 0xaa55

    