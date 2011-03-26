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
; 00: Address of next word
; 04: Flags
; 08: Name length
; 12: Name data
; XX: Word body, code field
; XX+08: Parameter field (if present)
;
; XX = align(12 + Name length), aligned to 4-byte boundary

        dict_len        equ     64*1024
        tib_len         equ     64*1024
        pstack_depth    equ     256
        rstack_depth    equ     128

;--------------------------------
section .data
;--------------------------------
        align   4
here_entry:
        dd      tib_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "here"          ; Word name
.nend: 
        align   4
here:   dd      doval, 0, dictionary_start_addr
;--------------------------------
        align   4
tib_entry:
        dd      old_tib_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "tib"           ; Word name
.nend:
        align   4
tib:    dd      doval, 0, tib_addr
;--------------------------------
        align   4
old_tib_entry:
        dd      number_tib_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "old-tib"       ; Word name
.nend:
        align   4
old_tib:
        dd      doconst, 0, tib_addr
;--------------------------------
        align   4
number_tib_entry:
        dd      to_in_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "#tib"          ; Word name
.nend:
        align   4
number_tib:
        dd      dovar, 0, 0
;--------------------------------
        align   4
to_in_entry:
        dd      state_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      ">in"           ; Word name
.nend:
        align   4
to_in:  dd      dovar, 0, 0
;--------------------------------
        align   4
state_entry:
        dd      tib_max_entry ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "state"         ; Word name
.nend:
        align   4
state:  dd      dovar, 0, 0
;--------------------------------
        align   4
tib_max_entry:
        dd      word_list_entry ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "tib-max"       ; Word name
.nend:
        align   4
tib_max:
        dd      doconst, 0, tib_len
;--------------------------------
        align   4
word_list_entry:
        dd      last_xt_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "word-list"     ; Word name
.nend:
        align   4
word_list:
        dd      dovar, 0, here_entry
;--------------------------------
        align   4
last_xt_entry:
        dd      argc_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "last-xt"       ; Word name
.nend:
        align   4
last_xt:
        dd      dovar, 0, 0

;--------------------------------
        align   4
argc_entry:
        dd      argv_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "argc"          ; Word name
.nend:
        align   4
argc:
        dd      doval, 0, 0

;--------------------------------
        align   4
argv_entry:
        dd      zero_char_entry ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "argv"          ; Word name
.nend:
        align   4
argv:
        dd      doval, 0, 0

;--------------------------------
        align   4
zero_char_entry:
        dd      a_char_entry    ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "0c"
.nend:
        align   4
zero_char:
        dd      doconst, 0, "0"
;--------------------------------
        align   4
a_char_entry:
        dd      ua_char_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "ac"
.nend:
        align   4
a_char:
        dd      doconst, 0, "a"
;--------------------------------
        align   4
ua_char_entry:
        dd      space_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "uac"
.nend:
        align   4
ua_char:
        dd      doconst, 0, "A"
;--------------------------------
        align   4
space_entry:
        dd      minus_char_entry        ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "space"
.nend:
        align   4
space:
        dd      doconst, 0, " "
;--------------------------------
        align   4
minus_char_entry:
        dd      enter_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "minus"
.nend:
        align   4
minus_char:
        dd      doconst, 0, "-"
;--------------------------------
true_addr:
        dd      doconst, 0, true_str_data
true_len:
        dd      doconst, 0, true_str_data.end-true_str_data
false_addr:
        dd      doconst, 0, false_str_data
false_len:
        dd      doconst, 0, false_str_data.end-false_str_data
prompt_addr:
        dd      doconst, 0, prompt_str_data
prompt_len:
        dd      doconst, 0, prompt_str_data.end-prompt_str_data
word_not_found_addr:
        dd      doconst, 0, word_not_found_str_data
word_not_found_len:
        dd      doconst, 0,
        dd      word_not_found_str_data.end-word_not_found_str_data
;--------------------------------
true_str_data:
        db      "True "
.end:
false_str_data:
        db      "False "
.end:
prompt_str_data:
        db      "Ok",10
.end:
word_not_found_str_data:
        db      " Word not found",10
.end:

        align   4

;--------------------------------
section .bss
;--------------------------------
        alignb  4
dictionary_start_addr:
        resb    dict_len
        alignb  4
        resd    pstack_depth
pstack_bottom:
tib_addr:
        resb    tib_len
        alignb  4
        resd    rstack_depth
rstack_bottom:
;--------------------------------
section .text
;--------------------------------
        global _start

_start:
        nop                     ; Makes gdb happy

        cld
        mov [argc+8], esp       ; Store pointer to command line arguments
                                ; count in argc variable
        mov eax, [esp]
        mov esi, start_ip       ; Initialize IP
        mov ebp, rstack_bottom  ; Initialize RSP
        mov esp, pstack_bottom  ; Initialize PSP
        mov edx, 0              ; Initialize TOS

        jmp next                ; Jump to interpreter

;--------------------------------
        align   4
next:
        mov eax, [esi]          ; Get next word address from thread
        lea esi, [esi+4]        ; Adjust IP
        mov edi, [eax]          ; X now points to machine code of next word
        jmp edi                 ; Jump to word machine code

;--------------------------------
        align   4
enter_entry:
        dd      dovar_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "do-enter"      ; Word name
.nend:
        align   4
        dd      doconst, 0, enter
enter:
        lea ebp, [ebp-4]        ; Add one cell on top of return stack
        mov [ebp], esi          ; Push IP on return stack
        lea esi, [eax+8]        ; Set IP to the parameter field
                                ; of current word
        jmp next                ; Jump to interpreter

;--------------------------------
        align   4
dovar_entry:
        dd      doconst_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "do-var"        ; Word name
.nend:
        align   4
        dd      doconst, 0, dovar
dovar:
        push edx                ; Push old TOS
        lea edx, [eax+8]        ; Get adress of parameter field
        jmp next

;--------------------------------
        align   4
doconst_entry:
        dd      doval_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "do-const"      ; Word name
.nend:
        align   4
        dd      doconst, 0, doconst
doconst:
        push edx                ; Push old TOS
        mov edx, [eax+8]        ; Load TOS from parameter field
        jmp next

;--------------------------------
        align   4
doval_entry:
        dd      dodoes_entry    ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "do-val"        ; Word name
.nend:
        align   4
        dd      doconst, 0, doval
doval   equ     doconst
;--------------------------------
        align   4
dodoes_entry:
        dd      exit_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "do-does"       ; Word name
.nend:
        align   4
        dd      doconst, 0, dodoes
dodoes:
        lea ebp, [ebp-4]        ; Add one cell on top of return stack
        mov [ebp], esi          ; Push IP on return stack
        push edx                ; Push one cell on parameter stack
        mov esi, [eax+4]        ; Set IP to DOES> entry for current word
        lea edx, [eax+8]        ; Set TOS to the parameter field
                                ; of current word
        jmp next                ; Jump to interpreter
;--------------------------------
        align   4
exit_entry:
        dd      swap_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "exit"          ; Word name
.nend:
        align   4
exit:                           ; --
        dd      exit+4          ; Code field
        mov esi, [ebp]          ; Pop IP from return stack
        lea ebp, [ebp+4]        ; Remove cell from return stack
        jmp next                ; Jump to interpreter
;--------------------------------
        align   4
swap_entry:
        dd      drop_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "swap"          ; Word name
.nend:
        align   4
swap:                           ; x1 x2 -- x2 x1
        dd      swap+4          ; Code field
        xchg edx, [esp]
        jmp next

;--------------------------------
        align   4
drop_entry:
        dd      dup_entry       ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "drop"          ; Word name
.nend:
        align   4
drop:                           ; x --
        dd      drop+4
        pop edx                 ; Get new TOS
        jmp next

;--------------------------------
        align   4
dup_entry:
        dd      over_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "dup"           ; Word name
.nend:
        align   4
dup:                            ; x -- x x
        dd      dup+4
        push edx                ; Push a copy of TOS on the stack
        jmp next

;--------------------------------
        align   4
over_entry:
        dd      rot_entry       ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "over"          ; Word name
.nend:
        align   4
over:                           ; x1 x2 -- x1 x2 x1
        dd      over+4
        push edx
        mov edx, [esp+4]
        jmp next

;--------------------------------
        align   4
rot_entry:
        dd      to_r_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "rot"           ; Word name
.nend:
        align   4
rot:                            ; x1 x2 x3 -- x2 x3 x1
        dd      rot+4
        xchg edx, [esp]         ; x1 x3 x2
        xchg edx, [esp+4]       ; x2 x3 x1
        jmp next

;--------------------------------
        align   4
to_r_entry:
        dd      r_to_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      ">r"            ; Word name
.nend:
        align   4
to_r:                           ; x -- ; R: -- x
        dd      to_r+4
        lea ebp, [ebp-4]        ; Add one cell on top of return stack
        mov [ebp], edx          ; Push TOS on return stack
        pop edx                 ; Fetch new TOS
        jmp next

;--------------------------------
        align   4
r_to_entry:
        dd      r_fetch_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "r>"            ; Word name
.nend:
        align   4
r_to:                           ; -- x ; R: x --
        dd      r_to+4
        push edx                ; Store old TOS
        mov edx, [ebp]          ; Pop TOS from return stack
        lea ebp, [ebp+4]        ; Remove one cell from return cell
        jmp next

;--------------------------------
        align   4
r_fetch_entry:
        dd      to_val_entry    ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "r@"            ; Word name
.nend:
        align   4
r_fetch:                        ; -- x; R: x -- x
        dd      r_fetch+4
        push edx                ; Store old TOS
        mov edx, [ebp]          ; Fetch TOS from return stack
        jmp next

;--------------------------------
        align   4
to_val_entry:
        dd      fetch_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "to"            ; Word name
.nend:
        align   4
to_val:                         ; x -- / Gets value address from thread
        dd      to_val+4
        mov eax, [esi]          ; Get address of next word
        mov [eax+8], edx        ; Store TOS inparameter field of next word
        lea esi, [esi+4]        ; Adjust IP
        pop edx                 ; Fetch new TOS
        jmp next

;--------------------------------
        align   4
fetch_entry:
        dd      store_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "@"             ; Word name
.nend:
        align   4
fetch:                          ; addr -- x
        dd      fetch+4         ; Code field
        mov edx, [edx]          ; Get X from ADDR
        jmp next                ; Jump to interpreter

;--------------------------------
        align   4
store_entry:
        dd      c_fetch_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "!"             ; Word name
.nend:
        align   4
store:                          ; x addr --
        dd      store+4         ; Code field
        pop ebx                 ; Get X value
        mov [edx], ebx          ; Store X at ADDR
        pop edx                 ; Get new TOS
        jmp next                ; Jump to interpreter

;--------------------------------
        align   4
c_fetch_entry:
        dd      c_store_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "c@"            ; Word name
.nend:
        align   4
c_fetch:                        ; addr -- c
        dd      c_fetch+4       ; Code field
        movzx edx, byte [edx]   ; Get C from ADDR
        jmp next                ; Jump to interpreter

;--------------------------------
        align   4
c_store_entry:
        dd      lit_entry       ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "c!"            ; Word name
.nend:
        align   4
c_store:                        ; char c-addr --
        dd      c_store+4       ; Code field
        pop ebx                 ; Get C value
        mov byte [edx], bl      ; Store C at ADDR
        pop edx                 ; Get new TOS
        jmp next                ; Jump to interpreter

;--------------------------------
        align   4
lit_entry:
        dd      jump_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "lit"           ; Word name
.nend:
        align   4
lit:                            ; -- x / x from thread
        dd      lit+4
        push edx                ; Store old TOS
        mov edx, [esi]          ; Read X from thread into TOS
        lea esi, [esi+4]        ; Adjust IP
        jmp next                ; Jump to interpreter

;--------------------------------
        align   4
jump_entry:
        dd      jump_if_not_entry       ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "do-jump"       ; Word name
.nend:
        align   4
        dd      doconst, 0, jump
jump:                           ; -- / addr from thread
        dd      jump+4
        mov esi, [esi]          ; Get new IP
        jmp next

;--------------------------------
        align   4
jump_if_not_entry:
        dd      execute_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "do-jump-if-not"        ; Word name
.nend:
        align   4
        dd      doconst, 0, jump_if_not
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

;--------------------------------
        align   4
execute_entry:
        dd      and_entry       ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "execute"       ; Word name
.nend:
        align   4
execute:                        ; i*x xt -- j*x
        dd      execute+4
        mov eax, edx            ; Get next word address from TOS
        mov edi, [eax]          ; X now points to machine code of XT
        pop edx                 ; Get new TOS
        jmp edi                 ; Jump to XT machine code

;--------------------------------
        align   4
and_entry:
        dd      or_entry        ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "and"           ; Word name
.nend:
        align   4
and:                            ; u1 u2 -- u
        dd      and+4           ; bit-and
        and edx, [esp]          ; TOS <- U1 and U2
        lea esp, [esp+4]        ; Remove u1 from stack
        jmp next

;--------------------------------
        align   4
or_entry:
        dd      zero_equals_entry       ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "or"            ; Word name
.nend:
        align   4
or:                             ; u1 u2 -- u
        dd      or+4            ; bit-or
        or edx, [esp]           ; TOS <- U1 or U2
        lea esp, [esp+4]        ; Remove u1 from stack
        jmp next

;--------------------------------
        align   4
zero_equals_entry:
        dd      equals_entry    ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "0="            ; Word name
.nend:
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

;--------------------------------
        align   4
equals_entry:
        dd      less_than_entry ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "="             ; Word name
.nend:
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

;--------------------------------
        align   4
less_than_entry:
        dd      greater_than_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "<"             ; Word name
.nend:
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

;--------------------------------
        align   4
greater_than_entry:
        dd      less_or_equal_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      ">"             ; Word name
.nend:
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

;--------------------------------
        align   4
less_or_equal_entry:
        dd      greater_or_equal_entry  ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "<="            ; Word name
.nend:
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

;--------------------------------
        align   4
greater_or_equal_entry:
        dd      negate_entry    ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      ">="            ; Word name
.nend:
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
;--------------------------------
        align   4
negate_entry:
        dd      plus_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "negate"
.nend:
        align   4
negate:                         ; n1 -- n2
        dd      negate+4
        neg edx                 ; Negate TOS
        jmp next
;--------------------------------
        align   4
plus_entry:
        dd      minus_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "+"             ; Word name
.nend:
        align   4
plus:                           ; n1 n2 -- n
        dd      plus+4
        pop ebx                 ; Get N1 from the stack
        add edx, ebx            ; Add N1 to TOS=N2
        jmp next                ; Jump to interpreter

;--------------------------------
        align   4
minus_entry:
        dd      mult_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "-"             ; Word name
.nend:
        align   4
minus:                          ; n1 n2 -- n
        dd      minus+4
        pop ebx                 ; Get N1 from the stack
        sub ebx, edx            ; Subtract TOS=N2 from N1
        mov edx, ebx            ; Move result to TOS
        jmp next                ; Jump to interpreter
;--------------------------------
        align   4
mult_entry:
        dd      umult_entry
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "*"             ; Word name
.nend:
        align   4
mult:                           ; n1 n2 -- n
        dd      mult+4
        imul edx, [esp]         ; Multiply N1 by N2 and put result into TOS
        lea esp, [esp+4]        ; Drop second element from parameter stack
        jmp next
;--------------------------------
        align   4
umult_entry:
        dd      div_mod_entry
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "u*"
.nend:
        align   4
umult:                          ; u1 u2 -- u3
        dd      umult+4
        pop eax                 ; Load U1 into EAX
        mul edx                 ; Multiply U1 by U2
        mov edx, eax            ; Store result into TOS
        jmp next
;--------------------------------
        align   4
div_mod_entry:
        dd      udiv_mod_entry  ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "/mod"          ; Word name
.nend:
        align   4
div_mod:                        ; n1 n2 -- n3 n4
        ; N3 = N1 mod N2
        ; N4 = N1 div N2
        dd      div_mod+4
        mov ebx, edx            ; Store N2 in EBX
        mov eax, [esp]          ; Store N1 in EAX
        cdq                     ; Sign-extend N1 to EDX:EAX
        idiv ebx                ; Signed divide N1 by N2
        mov [esp], edx          ; Store remainder as N3
        mov edx, eax            ; Store quotient as N4
        jmp next
;--------------------------------
        align   4
udiv_mod_entry:
        dd      lshift_entry    ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "u/mod"
.nend:
        align   4
udiv_mod:                       ; u1 u2 -- u3 u4
        ; U3 = U1 mod U2
        ; U4 = U1 div U2
        dd      udiv_mod+4
        mov ebx, edx            ; Store N2 in EBX
        mov eax, [esp]          ; Store N1 in EAX
        xor edx, edx            ; Zero-extend EAX to EDX:EAX
        div ebx                 ; Unsigned divide N1 by N2
        mov [esp], edx          ; Store remainder as N3
        mov edx, eax            ; Store quotient as N4
        jmp next
;--------------------------------
        align   4
lshift_entry:
        dd      rshift_entry    ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "lshift"        ; Word name
.nend:
        align   4
lshift:                         ; x1 u -- x2
        dd      lshift+4
        mov ecx, edx            ; Load count from TOS
        pop edx                 ; Get new TOS
        shl edx, cl             ; Perform left shift of TOS
        jmp next
;--------------------------------
        align   4
rshift_entry:
        dd      sys_print_entry ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "rshift"        ; Word name
.nend:
        align   4
rshift:                         ; x1 u -- x2
        dd      rshift+4
        mov ecx, edx            ; Load count from TOS
        pop edx                 ; Get new TOS
        shr edx, cl             ; Perform right shift of TOS
        jmp next
;--------------------------------
        align   4
sys_print_entry:
        dd      sys_read_entry  ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "sys-print"     ; Word name
.nend:
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

;--------------------------------
        align   4
sys_read_entry:
        dd      sys_exit_entry  ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "sys-read"      ; Word name
.nend:
        align   4
sys_read:                       ; addr u1 u2 -- u3
        dd      sys_read+4
        ; (buffer address) (buffer length) (handle)
        ; -- (bytes read)
        mov eax, 3              ; sys_read
        mov ebx, edx            ; Standard input
        pop edx                 ; Number of bytes to read from U1
        pop ecx                 ; Pop ADDR of buffer
        int 80h                 ; Make syscall
        mov edx, eax            ; Get new TOS
        jmp next
;--------------------------------
        align   4
sys_read_stdin_entry:
        dd      sys_exit_entry  ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "sys-read-stdin"        ; Word name
.nend:
        align   4
sys_read_stdin:                 ; addr u -- u1
        dd      enter, 0, lit, 0, sys_read, exit

;--------------------------------
        align   4
sys_exit_entry:
        dd      sys_open_ro_entry       ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "sys-exit"      ; Word name
.nend:
        align   4
sys_exit:                       ; --
        dd      sys_exit+4      ; Code field
        mov eax, 1              ; sys_exit
        mov ebx, 0              ; Return code 0 - success
        int 80h                 ; Make syscall

;--------------------------------
        align   4
sys_open_ro_entry:
        dd      sys_close_entry ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "sys-open-ro"   ; Word name
.nend:
        align   4
sys_open_ro:                    ; addr -- u
        ; Opens file with name addr (null-terminated string)
        ; and returns file handle
        dd      sys_open_ro+4   ; Code field
        mov eax, 5              ; sys_open
        mov ebx, edx            ; Address of filename from tOS
        mov ecx, 0              ; O_RDONLY
        int 80h                 ; Make syscall
        mov edx, eax            ; Store result handler in TOS
        jmp next

;--------------------------------
        align   4
sys_close_entry:
        dd      true_str_entry  ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "sys-close"     ; Word name
.nend:
        align   4
sys_close:                      ; u --
        ; Closes file handle
        dd      sys_close+4     ; Code field
        mov eax, 6              ; sys_close
        mov ebx, edx            ; Get file handle from TOS
        int 80h                 ; Make syscall
        pop edx                 ; Pop new TOS from stack
        jmp next

;--------------------------------
        align   4
true_str_entry:
        dd      false_str_entry ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "true-str"      ; Word name
.nend:
        align   4
true_str:                       ; -- addr u
        dd      enter, 0, true_addr, true_len, exit
;--------------------------------
        align   4
false_str_entry:
        dd      prompt_str_entry        ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "false-str"     ; Word name
.nend:
        align   4
false_str:                      ; -- addr u
        dd      enter, 0, false_addr, false_len, exit
;--------------------------------
        align   4
prompt_str_entry:
        dd      word_not_found_str_entry        ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "prompt-str"    ; Word name
.nend:
        align   4
prompt_str:                     ; -- addr u
        dd      enter, 0, prompt_addr, prompt_len, exit
;--------------------------------
        align   4
word_not_found_str_entry:
        dd      bool_point_entry        ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "word-not-found-str"    ; Word name
.nend:
        align   4
word_not_found_str:             ; -- addr u
        dd      enter, 0, word_not_found_addr, word_not_found_len, exit
;--------------------------------
        align   4
bool_point_entry:
        dd      fill_tib_entry        ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "b."            ; Word name
.nend:
        align   4
bool_point:                     ; b --
        ; Prints boolean parameter as "True" or "False"
        dd      enter, 0, jump_if_not, .else, true_str, sys_print, exit
.else:
        dd      false_str, sys_print, exit
;--------------------------------
        align   4
fill_tib_entry:
        dd      within_entry    ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "fill-tib"      ; Word name
.nend:
        align   4
fill_tib:                     ; --
        dd      enter, 0, tib, tib_max, sys_read_stdin
        dd      number_tib, store, lit, 0, to_in, store, exit
;--------------------------------
        align   4
within_entry:
        dd      plus_store_entry        ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "within"        ; Word name
.nend:
        align   4
within:                         ; n1 n2 n3 -- b
        ; Returns true iff n2 <= n1 < n3, comparison is signed
        dd      enter, 0, rot, swap, over, greater_than,
        dd      rot, rot, less_or_equal, and, exit
;--------------------------------
        align   4
plus_store_entry:
        dd      white_q_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "+!"            ; Word name
.nend:
        align   4
plus_store:                     ; u/n addr --
        dd      enter, 0, dup, fetch, rot, plus, swap, store, exit
;--------------------------------
        align   4
white_q_entry:
        dd      inside_tib_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "white?"        ; Word name
.nend:
        align   4
white_q:                        ; c -- b
        ; We consider 09-0d, 20 as whitespace
        ; (horizontal tab, line feed, vertical tab, form feed,
        ;  carriage return, space)
        dd      enter, 0, dup, lit, 09h, lit, 0eh, within
        dd      swap, lit, 20h, equals, or, exit
;--------------------------------
        align   4
inside_tib_entry:
        dd      drop_white_entry        ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "inside-tib?"   ; Word name
.nend:
        align   4
inside_tib:                   ; -- b
        dd      enter, 0, to_in, fetch, number_tib, fetch, less_than,
        dd      exit
;--------------------------------
        align   4
drop_white_entry:
        dd      get_word_entry  ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "drop-white"    ; Word name
.nend:
        align   4
drop_white:                     ; --
        ; Adjusts >IN to the first non-whitespace character
        dd      enter, 0
.iter:  dd      tib, to_in, fetch, plus, c_fetch, white_q,
        dd      jump_if_not, .end,
        dd      inside_tib, jump_if_not, .end,
        dd      lit, 1, to_in, plus_store, jump, .iter
.end:   dd      exit
;--------------------------------
        align   4
get_word_entry:
        dd      cmove_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "get-word"      ; Word name
.nend:
        align   4
get_word:                       ; -- addr u
        ; Reads a word from TIB starting at >IN
        ; Skips leading whitespace
        ; If end of TIB is reached returns length 0
        dd      enter, 0, drop_white, tib, to_in, fetch, plus
        dd      to_in, fetch
.iter:  dd      tib, to_in, fetch, plus, c_fetch, white_q, zero_equals
        dd      jump_if_not, .end
        dd      inside_tib, jump_if_not, .end,
        dd      lit, 1, to_in, plus_store, jump, .iter
.end:   dd      to_in, fetch, swap, minus, exit
;--------------------------------
        align   4
cmove_entry:
        dd      chars_equals_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "cmove"         ; Word name
.nend:
        align   4
cmove:                          ; c-addr1 c-addr2 u --
        ; Copy U characters starting from C-ADDR1 to C-ADDR2
        dd      enter, 0
.iter:  dd      dup, lit, 0, greater_than, jump_if_not, .end
        dd      rot, rot, over, c_fetch, over, c_store
        dd      lit, 1, plus, swap, lit, 1, plus, swap, rot
        dd      lit, 1, minus, jump, .iter
.end:   dd      drop, drop, drop
        dd      exit
;--------------------------------
        align   4
chars_equals_entry:
        dd      str_equals_entry        ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "chars="        ; Word name
.nend:
        align   4
chars_equals:                   ; c-addr1 c-addr2 u -- b
        ; Compares two strings with the same length for equality
        dd      enter, 0, to_r
.iter:  dd      r_to, dup, jump_if_not, .exit
        dd      lit, 1, minus, to_r
        dd      over, c_fetch, over, c_fetch, equals
        dd      rot, lit, 1, plus, rot, lit, 1, plus, rot
        dd      zero_equals, jump_if_not, .iter
        dd      drop, drop, r_to, drop, lit, 0, exit
.exit:  dd      drop, drop, drop, lit, -1, exit
;--------------------------------
        align   4
str_equals_entry:
        dd      str_to_dict_entry       ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "str="          ; Word name
.nend:
        align   4
str_equals:                     ; c-addr1 u1 c-addr2 u2 -- b
        ; Compares two strings for equality
        dd      enter, 0, rot, over, equals, jump_if_not, .diff_length
        dd      chars_equals, exit
.diff_length:
        dd      drop, drop, drop, lit, 0, exit
;--------------------------------
        align   4
str_to_dict_entry:
        dd      find_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "str>dict"      ; Word name
.nend:
        align   4
str_to_dict:                    ; c-addr u -- c-addr u
        ; Copies string (c-addr,u) to dictionary adjusting here pointer
        ; and returns pointer to stored string
        dd      enter, 0
        dd      to_r, here, r_fetch, cmove
        dd      here, r_fetch, here, r_to, plus, to_val, here, exit
;--------------------------------
        align   4
find_entry:
        dd      aligned_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "find"          ; Word name
.nend:
        align   4
find:                           ; c-addr u -- addr
        dd      enter, 0, word_list, fetch, to_r, jump, .start
.iter:
        dd      r_to, fetch, to_r
.start:
        dd      r_fetch, jump_if_not, .end
        dd      over, over, r_fetch, lit, 12, plus,
        dd      r_fetch, lit, 8, plus, fetch, str_equals
        dd      jump_if_not, .iter
        dd      drop, drop, r_to, exit
.end:
        dd      drop, drop, r_to, exit
;--------------------------------
        align   4
aligned_entry:
        dd      align_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "aligned"       ; Word name
.nend:
        align   4
aligned:                        ; addr -- a-addr
        dd      enter, 0, lit, 3, plus, lit, 2, rshift
        dd      lit, 2, lshift, exit
;--------------------------------
        align   4
align_entry:
        dd      to_body_entry   ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "align"         ; Word name
.nend:
        align   4
align_here:                     ; --
        dd      enter, 0, here, aligned, to_val, here, exit
;--------------------------------
        align   4
to_body_entry:
        dd      left_bracket_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      ">body"         ; Word name
.nend:
        align   4
to_body:
        dd      enter, 0, dup, lit, 8, plus, fetch
        dd      plus, lit, 12, plus, aligned, exit
;--------------------------------
        align   4
left_bracket_entry:
        dd      right_bracket_entry     ; Address of next word
        dd      -1              ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "["             ; Word name
.nend:
        align   4
left_barcket:                   ; -- (immediate)
        ; Changes state to interpret
        dd      enter, 0, lit, 0, state, store, exit
;--------------------------------
        align   4
right_bracket_entry:
        dd      eval_word_entry ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "]"             ; Word name
.nend:
        align   4
right_bracket:
        ; Changes state to compile
        dd      enter, 0, lit, -1, state, store, exit
;--------------------------------
        align   4
eval_word_entry:
        dd      comma_entry     ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "eval-word"     ; Word name
.nend:
        align   4
eval_word:                      ; i*x addr -- j*x
        ; Interprets or compiles a word according to system state
        ; and immediate flag of the word
        dd      enter, 0
        dd      state, fetch, jump_if_not, .exec
        dd      dup, lit, 4, plus, fetch, zero_equals, jump_if_not, .exec
        dd      to_body, comma, exit
.exec:  dd      to_body, execute, exit
;--------------------------------
        align   4
comma_entry:
        dd      create_entry    ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      ","             ; Word name
.nend:
        align   4
comma:                          ; x --
        dd      enter, 0, here, store
        dd      here, lit, 4, plus, to_val, here, exit
;--------------------------------
        align   4
create_entry:
        dd      zero_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "create"        ; Word name
.nend:
        align   4
create:                         ; "word" --
        dd      enter, 0,
        dd      get_word, dup, jump_if_not, .exit
        dd      here, aligned, to_val, here
        dd      here, to_r
        dd      word_list, fetch, comma
        dd      r_to, word_list, store
        dd      lit, 0, comma
        dd      dup, comma, dup, to_r
        dd      here, swap, cmove
        dd      r_to, here, plus, aligned, to_val, here,
        dd      here, last_xt, store
        dd      lit, dovar, comma, lit, 0, comma, exit
.exit:  dd      drop, drop, exit
;--------------------------------
        align   4
zero_entry:
        dd      one_entry       ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "0"             ; Word name
.nend:
        align   4
zero:                           ; -- u
        dd      enter, 0, lit, 0, exit
;--------------------------------
        align   4
one_entry:
        dd      four_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "1"             ; Word name
.nend:
        align   4
one:                            ; -- u
        dd      enter, 0, lit, 1, exit
;--------------------------------
        align   4
four_entry:
        dd      rep_loop_entry  ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "4"             ; Word name
.nend:
        align   4
four:                           ; -- u
        dd      enter, 0, lit, 4, exit
;--------------------------------
        align   4
rep_loop_entry:
        dd      main_entry      ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "rep-loop"      ; Word name
.nend:
        align   4
rep_loop:
        dd      enter, 0
.iter:  dd      get_word, dup, jump_if_not, .end
        dd      over, over
        dd      find, dup, jump_if_not, .err
        dd      swap, drop, swap, drop
        dd      eval_word, jump, .iter
.err:   dd      drop, sys_print, word_not_found_str, sys_print, sys_exit
        dd      jump, .iter
.end:   dd      drop, drop, exit
;--------------------------------
        align   4
main_entry:
        dd      0               ; Address of next word
        dd      0               ; Flags
        dd      .nend - .nst    ; Length of word name
.nst:   db      "main"          ; Word name
.nend:
        align   4
main:
        dd      enter, 0
        dd      lit, bootstrap_str, to_val, tib
        dd      lit, bootstrap_length, number_tib, store
        dd      lit, 0, to_in, store
        dd      rep_loop
        dd      old_tib, to_val, tib
        dd      fill_tib, rep_loop
        dd      sys_exit
;--------------------------------
start_ip:
        dd      main
;--------------------------------
bootstrap_length equ bootstrap_str.end - bootstrap_str
bootstrap_str:
db " create create-exec ] create do-enter last-xt @ ! exit [ "
db "    do-enter last-xt @ ! "
db " create-exec immediate ] 1 word-list @ 4 + ! exit [ "
db " create-exec postpone ] get-word find >body , exit [ immediate "
db " create-exec ; ] lit exit , postpone [ exit [ immediate "
db " create-exec : ] create-exec ] exit [ "

db " : nip swap drop ; "
db " : bye sys-exit ; "

db " : if do-jump-if-not , here 0 , ; immediate "
db " : else do-jump , here 0 , swap here swap ! ; immediate "
db " : endif here swap ! ; immediate "

db " : begin here ; immediate "
db " : again do-jump , , ; immediate "

db " : literal lit lit , , ; immediate "
db " : ' get-word find >body ; " ; "word" -- xt
db " : ['] lit lit , get-word find >body , ; immediate " ; "word" --

db " : variable create 0 , ; "
db " : value create do-val last-xt @ ! , ; "
db " : constant create do-const last-xt @ ! , ; "
db " : does> do-does last-xt @ ! r> last-xt @ 4 + ! ; "

db " : string: create 0 , does> dup 4 + swap @ ; "
db " : c' tib >in @ + 1 + c@ 1 1 + >in +! ; immediate " ; -- c
db " : [c'] postpone c' postpone literal ; immediate "
db " : len+! last-xt @ 4 + 4 + +! ; " ; u --
db " : +str swap over here swap cmove dup here + to here " ; addr u --
db      " len+! ; "
db " : +c here c! here 1 + to here 1 len+! ; " ; c --
db " : +c' postpone c' +c ; " ; --
db " : char-from-tib tib >in @ + c@ ; "
db " : skip-char begin dup char-from-tib = " ; c --
db      " if drop 1 >in +! exit endif "
db      " 1 >in +! again ; "
db ` : +s" 1 >in +! >in @ [c'] " skip-char `
db      " dup tib + swap >in @ swap - 1 - +str ; "

db " : pad here [ 4 4 4 4 * * * ] literal + ; "
db " variable base 4 4 1 1 + + + base ! "
db " : dig>char 0c + ; " ; u -- c
db " : u>str begin >r base @ u/mod swap dig>char r@ c! " ; u addr1 -- addr2
db      " dup 0= if drop r> exit endif r> 1 - again ; "
db " : u>pad space pad 1 + c! " ; u1 -- addr u2
db      " pad u>str pad [ 1 1 + ] literal + over - ; "
db " : u. u>pad sys-print ; " ; u --
db " : n>pad dup 0 < if " ; n -- addr u
db      " negate u>pad 1 + swap 1 - minus over c! swap exit endif "
db      " u>pad ; "
db " : . n>pad sys-print ; " ; n --

db " : char>dig 0c - ; " ; c -- u
db " : str>uint " ; addr u1 -- u1 b
db      " 0 >r begin dup 0= if drop drop r> 1 exit endif "
db      " over c@ char>dig r> "
db      " over 0 base @ within 0= if drop drop drop drop 0 0 exit endif "
db      " base @ u* + >r "
db      " 1 - swap 1 + swap again ; "
db " : str>int " ; addr u -- u|n b
db      " dup 0= if drop drop 0 0 exit endif "
db      " over c@ minus = if "
db              " dup 1 = if drop drop 0 0 exit endif "
db              " 1 - swap 1 + swap str>uint swap negate swap exit endif "
db      " str>uint ; "

db " : init argc 4 + to argv ; "        ; to doesn't work outside of
db " init "                             ; word definition

; Given a pointer to a null-terminated string
; returns its length
db " : length 0 begin "                 ; addr -- u
db      " over c@ 0 = if nip exit endif "
db      " 1 + swap 1 + swap again ; "

db " : eval-int state @ if lit lit , , endif ; "

db " : rep-loop begin "
db      " get-word dup 0= if drop drop exit endif "
db      " over over find dup if nip nip eval-word else "
db              " drop over over str>int if nip nip eval-int else "
db                      " drop sys-print word-not-found-str sys-print "
db                      " sys-exit "
db      " endif endif again ; "
db " : quit old-tib to tib fill-tib rep-loop quit ; "

db " quit "

.end:

