
macro PLATFORM_HEADER
{
format PE console
entry platform_start
}

macro PLATFORM_SECTION_DATA { section '.data' data readable writeable }

macro PLATFORM_SECTION_BSS
{
section '.bss' data readable writeable
        hStdout         rd      1
        hStdin          rd      1
        actual_bytes    rd      1
        argv_buf        rd      64
        str_buffer      rb      64*1024
}

macro PLATFORM_SECTION_CODE
{
local is_whitespace, arg_loop_next, arg_loop_start, \
        between_args, inside_arg, inside_quote, \
        switch_to_arg, switch_to_quote, switch_to_between, \
        done

section '.code' data executable readable

; Input dl = character
; Output z = 1 if character is whitespace
; Preserves all registers
is_whitespace:
        cmp dl, 20h     ; Compare input to ' '
        jz .return      ; If equals then return z = 1
        cmp dl, 09h     ; Compare input to '\t'
        jz .return      ; If equals then return z = 1
        cmp dl, 0ah     ; Compare input to '\n'
        jz .return      ; If equals then return z = 1
        cmp dl, 0dh     ; Compare input to '\r'
        ; Here we return result of last comparison
.return:
        ret

platform_start:

        ;; Here we get standard handles and store them into variables
        
        push -11                ; nStdHandle = -11 (standard output)
        call [GetStdHandle]     ; Get standard output handle
        mov [hStdout], eax      ; Store it in hStdout
        
        push -10                ; nStdHandle = -10 (standard input)
        call [GetStdHandle]     ; Get standard input handle
        mov [hStdin], eax       ; Store it in hStdin
        mov [stdin], eax        ; Store it in stdin constant
        
        ;; Here we parse command line into separate arguments
        
        call [GetCommandLine]
        ; eax - address of next character in input string
        ; ebx - address of next character in output string
        ; ecx - index of current argument
        ; dl  - next input character character
        ; esi - address of current mode
        mov ebx, str_buffer     ; Initialize address of next input character
        xor ecx, ecx            ; Initialize argument count to zero
        mov esi, between_args   ; Initialize mode to "between arg"
        mov [argv_buf], ebx     ; Store address of first argument in argv
        jmp arg_loop_start      ; Jump to start of loop

arg_loop_next:                  ; Next iteration of loop
        inc eax                 ; Update address of next input character
arg_loop_start:                 ; Loop start
        mov dl, [eax]           ; Read next character
        jmp esi                 ; Jump to mode-specific handler
        
between_args:                   ; Mode "between args"
        cmp dl, 0               ; If it's null character
        jz done                 ; we are done
        call is_whitespace      ; Check if next character is whitespace
        jz arg_loop_next        ; If it is jump to next character
        cmp dl, '"'             ; Check if the next character is double qoute
        jz switch_to_quote      ; If it is, switch to "inside quote" mode
        mov esi, inside_arg     ; Set mode to "inside arg"
                                ; Fall through to "inside arg" handler

inside_arg:                     ; Mode "inside args"
        cmp dl, 0               ; Check for the end of input
        jz switch_to_between    ; Finish this argument
        call is_whitespace      ; Check if next character is whitespace
        jz switch_to_between    ; If it is, current argument is over,
                                ; update argv
        cmp dl, '"'             ; Check if the next character is double qoute
        jz switch_to_quote      ; If it is, switch to "inside quote" mode
        mov [ebx], dl           ; Move character to output string
        inc ebx                 ; Update address of next output character
        jmp arg_loop_next       ; Jump to next character

inside_quote:
        cmp dl, 0               ; Check for the end of input
        jz switch_to_between    ; Finish this argument
        cmp dl, '"'             ; Check if the next character is double qoute
        jz switch_to_arg        ; If it is, switch to "inside arg" mode
        mov [ebx], dl           ; Move character to output string
        inc ebx                 ; Update address of next output character
        jmp arg_loop_next       ; Jump to next character

switch_to_arg:
        mov esi, inside_arg     ; Set mode to "inside arg"
        jmp arg_loop_next       ; Jump to next character
        
switch_to_quote:
        mov esi, inside_quote   ; Set mode to "inside quote"
        jmp arg_loop_next       ; Jump to next character
        
switch_to_between:
        mov esi, between_args   ; Set mode to "between args"
        mov byte [ebx], 0       ; Put NULL character at the end of
                                ; previous argument
        inc ebx                 ; Update address of next output character
        inc ecx                 ; Update argument count
        cmp dl, 0               ; Check for the end of input
        jz done                 ; If we are at the end of input, we are done
        mov [argv_buf + ecx*4], ebx ; Store address of next argument in
                                ; corresponding place of argv
        jmp arg_loop_next       ; Jump to next character

done:
        mov dword [argv_buf + ecx*4], 0 ; Store zero in argv after last argument
        mov [argc], ecx         ; Store argument count in argc
        mov [argv], argv_buf    ; Store address of arguments array in argv
        
        jmp start               ; Jump to common start for all platforms
}

macro PLATFORM_EXTRA
{
section '.idata' import data readable writable
        library kernel32, 'kernel32.dll'
        import kernel32, \
                ExitProcess, 'ExitProcess', \
                GetStdHandle, 'GetStdHandle', \
                WriteFile, 'WriteFile', \
                ReadFile, 'ReadFile', \
                GetCommandLine , 'GetCommandLineA', \
                CreateFile, 'CreateFileA', \
                CloseHandle, 'CloseHandle'
}

;; All platform-specific code must preserve ESI, EBP.
;; Inputs and outputs are stored in EDX, [ESP], [ESP+4], ...
;; If code does not use inputs it must preserve EDX
;; If it uses input and does not generate output,
;; it must do "pop edx" before continue

;; WinApi functions use stdcall convention.
;; They preserve EBX, ESI, EDI, EBP.
;; They return value in EAX and EDX.

; Writes data to standard output
; Input:
;       EDX = string length
;       Stack[0] = string address
macro PLATFORM_SYS_PRINT
{
        pop eax                 ; Pop address of string into EAX
        push 0                  ; lpOverlapped, not used
        push actual_bytes       ; Address of variable for storing number of
                                ; bytes actually written
        push edx                ; Number of bytes to write
        push eax                ; Address of string
        push [hStdout]          ; Standard output handle
        call [WriteFile]        ; Call WriteFile from kernel32.dll
        pop edx                 ; We consumed one input,
                                ; so we must fill EDX drom stack
}

; Reads data from file to buffer
; Input:
;       EDX = file handle
;       Stack[0] = maximum buffer length
;       Stack[1] = address of buffer
; Output:
;       EDX = number of bytes actually read
macro PLATFORM_SYS_READ
{
        local fixed

        pop eax                 ; Pop maximum buffer length
        
        cmp edx, [hStdin]       ; Compare file handle to standard input
        jne fixed               ; If it's not then Ok
        cmp eax, 16*1024        ; Compare buffer size to 16 KBytes
        jl fixed                ; If less then Ok
        mov eax, 16*1024        ; Otherwise fix buffer size to 16 KBytes
fixed:
        pop ebx                 ; Pop address of buffer
        push 0                  ; lpOverlapped, not used
        push actual_bytes       ; Address of variable for storing number of
                                ; bytes actually read
        push eax                ; Maximum buffer length
        push ebx                ; Address of buffer
        push edx                ; File handle
        call [ReadFile]         ; Call ReadFile from kernel32.dll
        mov edx, [actual_bytes] ; Return number of actual bytes read in EDX
}

; Reads data from standard input to buffer
; Input:
;       EDX = maximum buffer length
;       Stack[0] = address of buffer
; Output:
;       EDX = number of bytes actually read
macro PLATFORM_SYS_READ_STDIN
{
        local fixed

        cmp edx, 16*1024        ; Compare buffer size to 16 KBytes
        jl fixed                ; If less then Ok
        mov edx, 16*1024        ; Otherwise fix buffer size to 16 KBytes
fixed:
        pop eax                 ; Pop address of buffer
        push 0                  ; lpOverlapped, not used
        
        
        push actual_bytes       ; Address of variable for storing number of
                                ; bytes actually read
        push edx                ; Maximum buffer length
        push eax                ; Address of buffer
        push [hStdin]           ; File handle for standard input
        call [ReadFile]         ; Call ReadFile from kernel32.dll
        mov edx, [actual_bytes] ; Return number of actual bytes read in EDX
}

; Terminates program execution
; Input:
;       EDX = return code
macro PLATFORM_SYS_EXIT
{
        push edx                ; return code
        call [ExitProcess]      ; Terminate program
}

; Opens file for reading
; Input:
;       EDX = address of file name (null-terminated string)
; Output:
;       EDX = file handle
macro PLATFORM_SYS_OPEN_RO
{
        push 0                  ; hTemplateFile
        push 0x80               ; dwFlagsAndAttributes = FILE_ATTRIBUTE_NORMAL
        push 3                  ; dwCreationDisposition = OPEN_EXISTING
        push 0                  ; lpSecurityAttributes
        push 0x00000001         ; dwShareMode = FILE_SHARE_READ
        push 0x80000000         ; dwDesiredAccess = GENRIC_READ
        push edx                ; File name as null-terminated string
        call [CreateFile]       ; Open the file
        mov edx, eax            ; Store file handle in EDX
}

; Closes file
; Input:
;       EDX = file handle
macro PLATFORM_SYS_CLOSE
{
        push edx                ; File handle from EDX
        call [CloseHandle]      ; Close the handle
        pop edx                 ; Pop new TOS from stack
}

;; Macros for importing functions from DLL's

macro library [name, dll_file_name]
{
forward
    local   dll_str
    dd  RVA name#_ilt, 0, -1, RVA dll_str, RVA name#_iat
common
    dd  0, 0, 0, 0, 0
forward
    align   2
    dll_str     db  dll_file_name, 0
}

macro import dll_name, [name, external_name]
{
common
    align   4
    label   dll_name#_ilt   dword
forward
    local   name_hint
    dd  RVA name_hint
common
    dd      0
    label   dll_name#_iat   dword
forward
    name    dd  RVA name_hint
common
    dd      0
forward
    align   2
    name_hint  db  0, 0, external_name, 0
}

include "nforth.asm"
