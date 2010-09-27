section .data
        hello_str       db      "Hello, world!",10
        hello_str_len   equ     $-hello_str
        hello_str_ptr   dd      hello_str
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
; EBX: (W) working register - need not be preserved in code words
; ECX: -
; EDX: (TOS) top of parameter stack
; ESI: -
; EDI: -
; EBP: (RSP) return stack pointer
; ESP: (PSP) parameter stack pointer
; 

next:
        mov ebx, [eax]          ; W now points to code field of next word
        add eax, 4              ; Adjust IP to next word in thread
        mov esi, [ebx]          ; X now points to machine code of next word
        jmp esi                 ; Jump to word machine code

enter:
        sub ebp, 4              ; Add one cell on top of return stack
        mov [ebp], eax          ; Push IP on return stack
        lea eax, [ebx+4]        ; Set IP to the parameter field
                                ; of current word
        jmp next                ; Jump to interpreter

        align   4
exit:                           ; --
        dd      exit+4          ; Code field
        mov eax, [ebp]          ; Pop IP from return stack
        add ebp, 4              ; Remove cell from return stack
        jmp next                ; Jump to interpreter

        align   4
swap:                           ; x1 x2 -- x2 x1
        dd      swap+4          ; Code field
        xchg edx, [esp]
        jmp next

        align   4
deref:                          ; addr -- x
        dd      deref+4         ; Code field
        mov edx, [edx]
        jmp next

        align   4
hello:
        dd      hello+4
        push edx
        push hello_str_ptr
        mov edx, hello_str_len
        jmp next

        align   4
print:
        dd      print+4         ; Code field
        mov esi, eax            ; Save IP
        mov edi, edx            ; String length is already in edx
        mov eax, 4              ; sys_write
        mov ebx, 1              ; Standard output
        pop ecx                 ; Address of string
        int 80h                 ; Make syscall
        mov eax, esi            ; Restore IP
        pop edx                 ; Get new TOS
        jmp next                ; End of code

        align   4
sys_exit:
        dd      sys_exit+4      ; Code field
        mov eax, 1              ; sys_exit
        mov ebx, 0              ; Return code 0 - success
        int 80h                 ; Make syscall

        align   4
get_str:
        dd      enter, hello, swap, deref, swap, exit
main:
        dd      enter, get_str, get_str, print, print, sys_exit
start_ip:
        dd      main

_start:
        nop                     ; Makes gdb happy

        mov eax, start_ip       ; Initialize IP
        mov ebp, rstack_bottom  ; Initialize RSP
        mov esp, pstack_bottom  ; Initialize PSP
        mov edx, 0              ; Initialize TOS

        jmp next                ; Jump to interpreter

