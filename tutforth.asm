section .data
        test_str        db      "Hello, world!",10
        test_str_len    equ     $-test_str
section .bss
        alignb  4
        resd    64
pstack_bottom:
        resd    32
rstack_bottom:
section .text
        global _start

;--------------------------------
; This forth is implemented as indirect threaded code.
; Register allocation:
; 
; EAX: (IP) instruction pointer
; EBX: (W) working register
; ECX: -
; EDX: (X) second working register
; ESI: -
; EDI: -
; EBP: (RSP) return stack pointer
; ESP: (PSP) parameter stack pointer
; 

next:
        mov ebx, [eax]          ; W now points to code field of next word
        mov edx, [ebx]          ; X now points to machine code of next word
        jmp edx                 ; Jump to word machine code

enter:
        sub ebp, 4              ; Add one cell on top of return stack
        mov [ebp], eax          ; Push IP on return stack
        lea eax, [ebx+4]        ; Set IP to the parameter field
                                ; of current word
        jmp next                ; Jump to interpreter

exit:

        align   4
test_code_xt:
        dd      test_code_xt+4  ; address of first instruction
        mov eax, 4              ; sys_write
        mov ebx, 1              ; Standard output
        mov ecx, test_str       ; Address of string
        mov edx, test_str_len   ; Length of string
        int 80h                 ; Make syscall

        mov eax, 1              ; sys_exit
        mov ebx, 0              ; Return code 0 - success
        int 80h                 ; Make syscall

        jmp next                ; End of code

        align   4
test_itc_xt:
        dd      enter           ; Code field
        dd      test_code_xt
        dd      exit

start_ip:
        dd      test_itc_xt

_start:
        nop                     ; Makes gdb happy

        mov eax, start_ip       ; Initialize IP
        mov ebp, rstack_bottom  ; Initialize RSP
        mov esp, pstack_bottom  ; Initialize PSP

        jmp next                ; Jump to interpreter

