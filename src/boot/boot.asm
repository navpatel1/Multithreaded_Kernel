ORG 0x7c00
BITS 16

CODE_SEG EQU gdt_code - gdt_start
DATA_SEG EQU gdt_data - gdt_start

_start:
    jmp short start
    nop

times 33 db 0 ;padding for BPB

start:
    jmp 0:step2 ;it sets our code segment to 0x7c0 and offset becomes start

step2:
    cli
    mov ax,0x0     
    mov ds,ax    ;setting our data segment to 0x7c0 so DS:SI should work properly
    mov es,ax
    mov ss, ax   ;setting up stack segment to zero is still questionable 
    mov sp, 0x7c00 ;stack pointer is correct because we have bios datat area below 0x7c00
    sti

.load_protected:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1       ; Set PE bit
    mov cr0, eax
    jmp CODE_SEG:load32


gdt_start:
gdt_null:
    dd 0x0
    dd 0x0
gdt_code:
    dw 0xFFFF       ; Limit Low
    dw 0x0000       ; Base Low
    db 0x00         ; Base Middle
    db 10011010b    ; Access
    db 11001111b    ; Granularity
    db 0x00         ; Base High
gdt_data:
    dw 0xFFFF       ; Limit Low
    dw 0x0000       ; Base Low
    db 0x00         ; Base Middle
    db 10010010b    ; Access
    db 11001111b    ; Granularity
    db 0x00         ; Base High
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; Limit
    dd gdt_start               ; Base

[BITS 32]
load32:
    mov eax, 1 ;starting sector number
    mov ecx, 100 ;number of sectors to read
    mov edi, 0x0100000 ; Load address for kernel (1MB)
    call ata_lba_read
    jmp CODE_SEG:0x0100000 ;jump to loaded kernel

ata_lba_read:
    mov ebx,eax
    shr eax,24
    or eax,0xE0 ;setting up for lba mode and master drive
    mov dx, 0x1F6
    out dx,al
    ;finished sending highest 8 bits of lba

    mov eax, ecx
    mov dx, 0x1F2
    out dx,al
    ;finished sending number of sectors to read

    mov eax, ebx
    mov dx, 0x1F3
    out dx,al
    ;finished sending bits 0-7 of lba

    mov dx, 0x1F4
    mov eax, ebx
    shr eax,8
    out dx,al
    ;finished sending bits 8-15 of lba

    mov dx, 0x1F5
    mov eax, ebx
    shr eax,16
    out dx,al
    ;finished sending bits 16-23 of lba

    mov dx, 0x1F7
    mov al,0x20
    out dx,al
    ;sent read command

.read_sector:
    ;wait for drive to be ready
    push ecx
.wait_status:
    mov dx,0x1F7
    in al,dx
    test al,0x80
    jnz .wait_status    
    ;we need to read 256 word at a time
    mov ecx,256
    mov dx,0x1F0
    rep insw
    pop ecx
    loop .read_sector
    ret

HEIGHT EQU 25
WIDTH  EQU 80
msg db 'Welcome to My kernel OS!',0
zero_msg db 'Divide by Zero Exception Handler Invoked!',0
err_msg db 'Failed to load a sector from disk!',0
times 510-($-$$) db 0
dw 0xaa55