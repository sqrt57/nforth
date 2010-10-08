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
;
;--------------------------------
; Dictionary entry structure:
; 00 +-------------------------
;    | Address of next word
; 04 +-------------------------
;    | 
; 

        tiblen     equ     128

section .data
        align   4
cell_pair:
        dd      dovar, 0, 0, 0
hello_addr:
        dd      dovar, 0
.begin: db "Hello, world!",10
.end:
        align   4
hello_len:
        dd      doconst, 0, hello_addr.end-hello_addr.begin
here:
        dd      doval, 0, dict_addr
t_i_b:
        dd      doconst, 0, tib_addr
number_t_i_b:
        dd      dovar, 0, 0
to_in:
        dd      dovar, 0, 0
t_i_b_max:
        dd      doconst, 0, tiblen

section .bss
        alignb  4
dict_addr:
        resd    1024
pstack_bottom:
tib_addr:
        resb    tiblen
        alignb  4
        resd    32
rstack_bottom:
section .text
        global _start

_start:
        nop                     ; Makes gdb happy

        cld
        mov esi, start_ip       ; Initialize IP
        mov ebp, rstack_bottom  ; Initialize RSP
        mov esp, pstack_bottom  ; Initialize PSP
        mov edx, 0              ; Initialize TOS

        jmp next                ; Jump to interpreter

        align   4
next:
        mov eax, [esi]          ; Get next word address from thread
        lea esi, [esi+4]        ; Adjust IP
        mov edi, [eax]          ; X now points to machine code of next word
        jmp edi                 ; Jump to word machine code

        align   4
enter:
        lea ebp, [ebp-4]        ; Add one cell on top of return stack
        mov [ebp], esi          ; Push IP on return stack
        lea esi, [eax+8]        ; Set IP to the parameter field
                                ; of current word
        jmp next                ; Jump to interpreter

        align   4
dovar:
        push edx                ; Push old TOS
        lea edx, [eax+8]        ; Get adress of parameter field
        jmp next

        align   4
doconst:
        push edx                ; Push old TOS
        mov edx, [eax+8]        ; Load TOS from parameter field
        jmp next

doval   equ     doconst

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
to_val:                         ; x -- / Gets value address from thread
        dd      to_val+4
        mov eax, [esi]          ; Get address of next word
        mov [eax+8], edx        ; Store TOS inparameter field of next word
        lea esi, [esi+4]        ; Adjust IP
        pop edx                 ; Fetch new TOS
        jmp next

        align   4
fetch:                          ; addr -- x
        dd      fetch+4         ; Code field
        mov edx, [edx]          ; Get X from ADDR
        jmp next                ; Jump to interpreter

        align   4
store:                          ; x addr --
        dd      store+4         ; Code field
        pop ebx                 ; Get X value
        mov [edx], ebx          ; Store X at ADDR
        pop edx                 ; Get new TOS
        jmp next                ; Jump to interpreter

        align   4
c_fetch:                        ; addr -- c
        dd      c_fetch+4       ; Code field
        movzx edx, byte [edx]   ; Get C from ADDR
        jmp next                ; Jump to interpreter

        align   4
c_store:                        ; c addr --
        dd      c_store+4       ; Code field
        pop ebx                 ; Get C value
        mov byte [edx], bl      ; Store C at ADDR
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
zero_equals:                        ; b -- b
        dd      zero_equals+4
        xor eax, eax            ; Zero EAX
        cmp edx, eax            ; Compare TOS to 0
        jnz .continue           ; If TOS!=0 then EAX=0 is what we need,
                                ; so we skip decrement
        dec eax                 ; EAX is now -1
.continue:
        mov edx, eax            ; Store EAX value to TOS
        jmp next

        align   4
plus:                           ; n1 n2 -- n
        dd      plus+4
        pop ebx                 ; Get N1 from the stack
        add edx, ebx            ; Add N1 to TOS=N2
        jmp next                ; Jump to interpreter

        align   4
minus:                          ; n1 n2 -- n
        dd      minus+4
        pop ebx                 ; Get N1 from the stack
        sub ebx, edx            ; Subtract TOS=N2 from N1
        mov edx, ebx            ; Move result to TOS
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
read:                           ; addr u -- u
        dd      read+4
        mov eax, 4              ; sys_read
        mov ebx, 0              ; Standard input
        pop ecx                 ; Pop ADDR of buffer from pstack
                                ; Number of bytes to read is already
                                ; in EDX=TOS
        int 80h                 ; Make syscall
        pop edx                 ; Get new TOS
        jmp next

        align   4
sys_exit:                       ; --
        dd      sys_exit+4      ; Code field
        mov eax, 1              ; sys_exit
        mov ebx, 0              ; Return code 0 - success
        int 80h                 ; Make syscall

        align   4
hello:                          ; -- addr u
        dd      enter, 0, hello_addr, hello_len, exit
store_char:                     ; addr --
        dd      enter, 0, c_fetch, here, c_store, exit
one_char:                       ; addr -- addr
        dd      enter, 0, dup, store_char
        dd      here, lit, 1, plus, to_val, here
        dd      lit, 1, plus, exit
                                ; addr -- addr
store_str:                      ; addr u -- addr
        dd      enter, 0, swap, over            ; u addr u
.iter:
        dd      dup, jump_if_not, .end, lit, 1, minus
        dd      swap, one_char, swap
        dd      jump, .iter
.end:
        dd      drop, drop, here, swap, minus, exit
cycle:
        dd      enter, 0, lit, -20
.iter:  dd      get_str, print, lit, 4, plus, dup, zero_equals
        dd      jump_if_not, .iter, exit
cell1:                          ; -- addr
        dd      enter, 0, cell_pair, exit
cell2:                          ; -- addr
        dd      enter, 0, cell_pair, lit, 4, plus, exit
get_str:                        ; -- addr u
        dd      enter, 0, cell2, fetch, cell1, fetch, exit
init:                           ; --
        dd      enter, 0, hello, dup, cell1, store, store_str,
        dd      cell2, store, exit
main:
        dd      enter, 0, init, cycle, sys_exit
start_ip:
        dd      main

