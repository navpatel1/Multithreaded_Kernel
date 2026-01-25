sectin .data
    msg BYTE "Hello, World!", 0
    msg_len EQU $ - msg

section .text
    global _start

_start:
    mov eax , 4          ; syscall: sys_write
    mov ebx , 1          ; file descriptor: stdout
    mov ecx , msg        ; pointer to message
    mov edx , msg_len    ; message length
    int 0x80             ; call kernel
    mov eax , 1          ; syscall: sys_exit
    xor ebx , ebx        ; exit code 0
    int 0x80             ; call kernel
