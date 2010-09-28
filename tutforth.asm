section .data
        hello_str       db      "Hello, world!",10
        hello_str_len   equ     $-hello_str
        hello_str_ptr   dd      hello_str
section .bss
        alignb  4
dictionary:
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
; EAX: (W) working register - need not be preserved in code words
; EBX: -
; ECX: -
; EDX: (TOS) top of parameter stack
; ESI: (IP) instruction pointer
; EDI: -
; EBP: (RSP) return stack pointer
; ESP: (PSP) parameter stack pointer

_start:
        nop                     ; Makes gdb happy

        cld
        mov esi, start_ip       ; Initialize IP
        mov ebp, rstack_bottom  ; Initialize RSP
        mov esp, pstack_bottom  ; Initialize PSP
        mov edx, 0              ; Initialize TOS

        jmp next                ; Jump to interpreter

next:
        mov eax, [esi]          ; Get next word address from thread
        lea esi, [esi+4]        ; Adjust IP
        mov edi, [eax]          ; X now points to machine code of next word
        jmp edi                 ; Jump to word machine code

enter:
        lea ebp, [ebp-4]        ; Add one cell on top of return stack
        mov [ebp], esi          ; Push IP on return stack
        lea esi, [eax+4]        ; Set IP to the parameter field
                                ; of current word
        jmp next                ; Jump to interpreter

        align   4
exit:                           ; --
        dd      exit+4          ; Code field
        mov esi, [ebp]          ; Pop IP from return stack
        lea ebp, [ebp+4]        ; Remove cell from return stack
        jmp next                ; Jump to interpreter

        align   4
swap:                           ; x1 x2 -- x2 x1
        dd      swap+4          ; Code field
        xchg edx, [esp]
        jmp next

        align   4
drop:                           ; x --
        dd      drop+4
        pop edx                 ; Get new TOS
        jmp next

        align   4
dup:                            ; x -- x x
        dd      dup+4
        push edx                ; Push a copy of TOS on the stack
        jmp next

        align   4
over:                           ; x1 x2 -- x1 x2 x1
        dd      over+4
        push edx
        mov edx, [esp+4]
        jmp next

        align   4
get:                            ; addr -- x
        dd      get+4           ; Code field
        mov edx, [edx]          ; Get X from ADDR
        jmp next                ; Jump to interpreter

        align   4
put:                            ; x addr --
        dd      put+4           ; Code field
        pop ebx                 ; Get X value
        mov [edx], ebx          ; Store X at ADDR
        pop edx                 ; Get new TOS
        jmp next                ; Jump to interpreter

        align   4
lit:                            ; -- x / x from thread
        dd      lit+4
        push edx                ; Store old TOS
        lodsd                   ; Get X from thread and adjust IP
        mov edx, eax            ; Store X in TOS
        jmp next                ; Jump to interpreter

        align   4
jump:                           ; -- / addr from thread
        dd      jump+4
        mov esi, [esi]          ; Get new IP
        jmp next

        align   4
jump_if_not:                    ; b -- / addr from thread
        ; Jumps if TOS=0 (false)
        dd      jump_if_not+4
        lea esi, [esi+4]        ; If we don't take a jump we must skip
                                ; jump address in the thread
        xor eax, eax            ; Zero EAX
        cmp edx, eax            ; Compare TOS to 0
        jnz .continue           ; If B!=0 we skip updating IP
        mov esi, [esi-4]        ; Get new IP (if TOS=0)
.continue:
        pop edx                 ; get new TOS
        jmp next

        align   4
zero_eq:                        ; b -- b
        dd      zero_eq+4
        xor eax, eax            ; Zero EAX
        cmp edx, eax            ; Compare TOS to 0
        jnz .continue           ; If TOS!=0 then EAX=0 is what we need,
                                ; so we skip decrement
        dec eax                 ; EAX is now -1
.continue:
        mov edx, eax            ; Store EAX value to TOS
        jmp next

        align   4
add:                            ; n1 n2 -- n
        dd      add+4
        pop ebx                 ; Get N1 from the stack
        add edx, ebx            ; Add N1 to TOS=N2
        jmp next                ; Jump to interpreter

        align   4
hello:                          ; -- addr u
        dd      hello+4
        push edx
        push hello_str
        mov edx, hello_str_len
        jmp next

        align   4
dict:                           ; -- addr
        dd      dict+4
        push edx                ; Store old TOS
        mov edx, dictionary     ; Get ADDR of dictionary
        jmp next                ; Jump to interpreter

        align   4
print:                          ; addr u --
        dd      print+4         ; Code field
                                ; String length is already in edx (TOS)
        mov eax, 4              ; sys_write
        mov ebx, 1              ; Standard output
        pop ecx                 ; Address of string
        int 80h                 ; Make syscall
        pop edx                 ; Get new TOS
        jmp next                ; End of code

        align   4
sys_exit:                       ; --
        dd      sys_exit+4      ; Code field
        mov eax, 1              ; sys_exit
        mov ebx, 0              ; Return code 0 - success
        int 80h                 ; Make syscall

        align   4
cycle:
        dd      enter, lit, -40
.iter:
        dd      get_str, print, lit, 4, add, dup, zero_eq,
        dd      jump_if_not, .iter, exit
cell1:                          ; -- addr
        dd      enter, dict, exit
cell2:                          ; -- addr
        dd      enter, dict, lit, 4, add, exit
get_str:                        ; -- addr u
        dd      enter, cell2, get, cell1, get, exit
init:                           ; --
        dd      enter, hello, cell1, put, cell2, put, exit
main:
        dd      enter, init, cycle, sys_exit
start_ip:
        dd      main

