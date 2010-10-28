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

        tiblen     equ     1024

section .data
        align   4
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
true_addr:
        dd      doconst, 0, true_str_data
true_len:
        dd      doconst, 0, true_str_data.end-true_str_data
false_addr:
        dd      doconst, 0, false_str_data
false_len:
        dd      doconst, 0, false_str_data.end-false_str_data
true_str_data:
        db      "True",10
.end:
false_str_data:
        db      "False",10
.end:

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
rot:                            ; x1 x2 x3 -- x2 x3 x1
        dd      rot+4
        xchg edx, [esp]         ; x1 x3 x2
        xchg edx, [esp+4]       ; x2 x3 x1
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
        mov edx, [esi]          ; Read X from thread into TOS
        lea esi, [esi+4]        ; Adjust IP
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
and:                            ; u1 u2 -- u
        dd      and+4           ; bit-and
        and edx, [esp]          ; TOS <- U1 and U2
        lea esp, [esp+4]        ; Remove u1 from stack
        jmp next

        align   4
or:                             ; u1 u2 -- u
        dd      or+4            ; bit-or
        or edx, [esp]           ; TOS <- U1 or U2
        lea esp, [esp+4]        ; Remove u1 from stack
        jmp next

        align   4
zero_equals:                    ; b -- b
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
equals:                         ; n/u1 n/u2 -- b
        dd      equals+4
        xor eax, eax            ; Zero EAX
        cmp [esp], edx          ; Compare N1 to TOS=N2
        jne .continue           ; If not N1=N2 then skip
        dec eax                 ; If N1=N2 set EAX to TRUE
.continue:
        lea esp, [esp+4]        ; Remove n1 from parameter stack
        mov edx, eax            ; Store result in TOS
        jmp next

        align   4
less_than:                      ; n1 n2 -- b
        dd      less_than+4
        xor eax, eax            ; Zero EAX
        cmp [esp], edx          ; Compare N1 to TOS=N2
        jnl .continue           ; If not N1<N2 then skip
        dec eax                 ; If N1<N2 set EAX to TRUE
.continue:
        lea esp, [esp+4]        ; Remove n1 from parameter stack
        mov edx, eax            ; Store result in TOS
        jmp next

        align   4
greater_than:                   ; n1 n2 -- b
        dd      greater_than+4
        xor eax, eax            ; Zero EAX
        cmp [esp], edx          ; Compare N1 to TOS=N2
        jng .continue           ; If not N1>N2 then skip
        dec eax                 ; If N1>N2 set EAX to TRUE
.continue:
        lea esp, [esp+4]        ; Remove n1 from parameter stack
        mov edx, eax            ; Store result in TOS
        jmp next

        align   4
less_or_equal:                  ; n1 n2 -- b
        dd      less_or_equal+4
        xor eax, eax            ; Zero EAX
        cmp [esp], edx          ; Compare N1 to TOS=N2
        jnle .continue          ; If not N1<=N2 then skip
        dec eax                 ; If N1<=N2 set EAX to TRUE
.continue:
        lea esp, [esp+4]        ; Remove n1 from parameter stack
        mov edx, eax            ; Store result in TOS
        jmp next

        align   4
greater_or_equal:               ; n1 n2 -- b
        dd      greater_or_equal+4
        xor eax, eax            ; Zero EAX
        cmp [esp], edx          ; Compare N1 to TOS=N2
        jnge .continue          ; If not N1>=N2 then skip
        dec eax                 ; If N1>=N2 set EAX to TRUE
.continue:
        lea esp, [esp+4]        ; Remove n1 from parameter stack
        mov edx, eax            ; Store result in TOS
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
sys_print:                      ; addr u --
        dd      sys_print+4     ; Code field
                                ; String length is already in edx (TOS)
        mov eax, 4              ; sys_write
        mov ebx, 1              ; Standard output
        pop ecx                 ; Address of string
        int 80h                 ; Make syscall
        pop edx                 ; Get new TOS
        jmp next                ; End of code

        align   4
sys_read:                       ; addr u -- u
        dd      sys_read+4
        mov eax, 3              ; sys_read
        mov ebx, 0              ; Standard input
        pop ecx                 ; Pop ADDR of buffer from pstack
                                ; Number of bytes to read is already
                                ; in EDX=TOS
        int 80h                 ; Make syscall
        mov edx, eax            ; Get new TOS
        jmp next

        align   4
sys_exit:                       ; --
        dd      sys_exit+4      ; Code field
        mov eax, 1              ; sys_exit
        mov ebx, 0              ; Return code 0 - success
        int 80h                 ; Make syscall

        align   4
true_str:                       ; -- addr u
        dd      enter, 0, true_addr, true_len, exit
false_str:                      ; -- addr u
        dd      enter, 0, false_addr, false_len, exit
point_bool:                     ; b --
        ; Prints boolean parameter as "True" or "False"
        dd      enter, 0, jump_if_not, .else, true_str, sys_print, exit
.else:
        dd      false_str, sys_print, exit
fill_t_i_b:                     ; --
        dd      enter, 0, t_i_b, t_i_b_max, sys_read
        dd      number_t_i_b, store, lit, 0, to_in, store, exit
within:                         ; n1 n2 n3 -- b
        ; Returns true iff n2 <= n1 < n3, comparison is signed
        dd      enter, 0, rot, swap, over, greater_than,
        dd      rot, rot, less_or_equal, and, exit
plus_store:                     ; u/n addr --
        dd      enter, 0, dup, fetch, rot, plus, swap, store, exit
white_q:                        ; c -- b
        ; We consider 09-0d, 20 as whitespace
        ; (horizontal tab, line feed, vertical tab, form feed,
        ;  carriage return, space)
        dd      enter, 0, dup, lit, 09h, lit, 0eh, within
        dd      swap, lit, 20h, equals, or, exit
inside_t_i_b:                   ; -- b
        dd      enter, 0, to_in, fetch, number_t_i_b, fetch, less_than,
        dd      exit
drop_white:                     ; --
        ; Adjusts >IN to the first non-whitespace character
        dd      enter, 0
.iter:  dd      t_i_b, to_in, fetch, plus, c_fetch, white_q,
        dd      jump_if_not, .end,
        dd      inside_t_i_b, jump_if_not, .end,
        dd      lit, 1, to_in, plus_store, jump, .iter
.end:   dd      exit
get_word:                       ; -- addr u
        ; Reads a word from TIB starting at >IN
        ; Skips leading whitespace
        ; If end of TIB is reached returns length 0
        dd      enter, 0, drop_white, t_i_b, to_in, fetch, plus
        dd      to_in, fetch
.iter:  dd      t_i_b, to_in, fetch, plus, c_fetch, white_q, zero_equals
        dd      jump_if_not, .end
        dd      inside_t_i_b, jump_if_not, .end,
        dd      lit, 1, to_in, plus_store, jump, .iter
.end:   dd      to_in, fetch, swap, minus, exit
test_tib:
        dd      enter, 0, fill_t_i_b, drop_white
        dd      t_i_b, to_in, fetch, plus, number_t_i_b, fetch
        dd      sys_print, t_i_b, c_fetch, white_q, point_bool, sys_exit
main:
        dd      enter, 0, fill_t_i_b, get_word, sys_print, sys_exit
start_ip:
        dd      main

