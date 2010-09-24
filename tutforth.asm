section .data
section .bss
section .text
        global _start

_start:
        nop                     ; Makes gdb happy


        mov ebx, 0              ; Return code 0 - success
        mov eax, 1              ; Specify exit syscall
        int 80h                 ; Make syscall

