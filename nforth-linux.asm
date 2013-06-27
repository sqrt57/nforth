
macro PLATFORM_HEADER
{
format ELF executable 
entry platform_start
}


macro PLATFORM_SECTION_DATA { segment readable writeable }

macro PLATFORM_SECTION_BSS { segment writeable }

macro PLATFORM_SECTION_CODE
{
segment readable executable
platform_start:
        nop                     ; Makes gdb happy

        mov [argc], esp         ; Store pointer to
                                ; command line arguments count
                                ; in argc variable
                                
        lea eax, [esp+4]        ; Store pointer to
        mov [argv], eax         ; command line arguments array
                                ; in argv variable

        mov [stdin], 0          ; Initialize stdin constant
                                
        jmp start               ; Jump to common start for all platforms
}


macro PLATFORM_EXTRA {}

;; All platform-specific code must preserve EDX, ESI, EBP
;; It can freely modify all other registers

; Writes data to standard output
; Input:
;       EDX = string length
;       stack top = string address
macro PLATFORM_SYS_PRINT
{
                                ; String length is already in edx (TOS)
        mov eax, 4              ; sys_write
        mov ebx, 1              ; Standard output
        pop ecx                 ; Address of string
        int 80h                 ; Make syscall
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
        mov eax, 3              ; sys_read
        mov ebx, edx            ; File handle
        pop edx                 ; Number of bytes to read from U1
        pop ecx                 ; Pop address of buffer
        int 80h                 ; Make syscall
                                ; Number of bytes read is in EAX
        mov edx, eax            ; Return value is in EDX
}

; Reads data from standard input to buffer
; Input:
;       EDX = maximum buffer length
;       Stack[0] = address of buffer
; Output:
;       EDX = number of bytes actually read
macro PLATFORM_SYS_READ_STDIN
{
        mov eax, 3              ; sys_read
        mov ebx, 0              ; File handle for standard input
                                ; Number of bytes to read is already in EDX
        pop ecx                 ; Pop address of buffer
        int 80h                 ; Make syscall
                                ; Number of bytes read is in EAX
        mov edx, eax            ; Return value is in EDX
}

; Terminates program execution
; Input:
;       EDX = return code
macro PLATFORM_SYS_EXIT
{
        mov eax, 1              ; sys_exit
        mov ebx, edx            ; Return code
        int 80h                 ; Make syscall
}

; Opens file for reading
; Input:
;       EDX = address of file name (null-terminated string)
; Output:
;       EDX = file handle
macro PLATFORM_SYS_OPEN_RO
{
        mov eax, 5              ; sys_open
        mov ebx, edx            ; Address of filename from EDX
        mov ecx, 0              ; O_RDONLY
        int 80h                 ; Make syscall
        mov edx, eax            ; Return value in EDX
}

; Closes file
; Input:
;       EDX = file handle
macro PLATFORM_SYS_CLOSE
{
        mov eax, 6              ; sys_close
        mov ebx, edx            ; Get file handle from EDX
        int 80h                 ; Make syscall
        pop edx                 ; Pop new TOS from stack
}

include "nforth.asm"