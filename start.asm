; Name: Adam Sellers
; email: adamsellers2020@csu.fullerton.edu
; Section: MW 2:00 - 3:50
; Program name: Accurate cosine
; Start date: 10/26/22
; Last updated: _________

; TO RUN:
;   ./r.sh
;   ./cosine.out

global _start

; Declare externals
extern itoa
extern ftoa
extern atof
extern scan

; Read/Write/Terminate
sys_read equ 0
sys_write equ 1
sys_terminate equ 60

null equ 0
exit_with_success equ 0
line_feed equ 10

; Constants
stdin equ 0
stdout equ 1
stderror equ 2

size_str_clock equ 64
size_str_angle equ 32
size_str_radians equ 30

section .data

str_welcome db "Welcome to Accurate Cosines by Adam Sellers.",10,0 ; len = 46
str_goodbye db "Have a nice day. Bye.",10,0 ; len = 23

str_time1 db "The time is now ",0 ; len = 17
str_time2 db " tics",10,0 ; len = 6

str_angle_entry db "Please enter an angle in degrees and press enter: ",0 ;len = 51
str_angle_display db "You entered ",0 ; len = 13

str_newline db " ",10,0 ; len = 3?

str_radian_display db "The equivalent radians is ",0 ; len = 27

section .bss

int_array_clock resb size_str_clock     ;64 bytes
chr_array_clock resb size_str_clock     ;64 bytes

chr_array_angle resb size_str_angle     ;32 bytes
float_angle resb size_str_angle         ;32 bytes

float_radians resb size_str_radians     ;32 bytes
chr_array_radians resb size_str_radians ;32 bytes

section .text

_start:
; GENERAL LAYOUT (Check that each compiles and executes before moving to next step)

; 1A) WECLOME AND GOODBYE MESSAGE

    ; Display welcome message:
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, str_welcome
    mov rdx, 46
    syscall


; 2A) DISPLAY START TIME IN TICS

    ; 0 out rdx and rdx
    mov rax, 0
    mov rdx, 0

    ; Get current tic count and store in rdx and rax
    cpuid           ; Pause system clock
    rdtsc           ; Store system clock time into rax and rdx
    shl rdx, 32     ; Bitshift rdx 32 bits left 
    or rdx, rax     ; All 64 bits in rdx

    ; Convert time stamp rdx into string 
    mov rax, 0
    mov rdi, rdx                ; rdi = 64 bit integer to be converted into a string
    mov rsi, chr_array_clock    ; rsi = starting address of the string that will recieve the converted integer
    call itoa
    mov r15, chr_array_clock

    ; Display chr_array_clock
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, str_time1
    mov rdx, 17
    syscall

    mov rax, sys_write
    mov rdi, stdout
    mov rsi, chr_array_clock
    mov rdx, size_str_clock
    syscall

    mov rax, sys_write
    mov rdi, stdout
    mov rsi, str_time2
    mov rdx, 6
    syscall

; 3) ENTER ANGLE AS STRING

    ; Prompt for string
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, str_angle_entry
    mov rdx, 51
    syscall

    mov rbx, chr_array_angle    ; put address of string into rbx
    mov r12, 0                  ; r12 = loop counter
    push qword 0                ; Allocate space for byte

    begin_loop:
        
        mov rax, sys_read ; read a byte and put on top of stack rsp
        mov rdi, stdin
        mov rsi, rsp
        mov rdx, 1 ; read one byte
        syscall

        mov al, byte [rsp]  ; put the byte from the stack into al
        cmp al, line_feed   ; check for [Enter] (newline), if [Enter], exit
        je exit_loop

        inc r12

        ; Check for overflow
        cmp r12, size_str_angle
        ; if (r12 >= size)
        jge end_if_else ;pass
        ; else (r12 < size)
        mov byte [rbx], al
        inc rbx
        end_if_else:

        jmp begin_loop
        
    exit_loop:

; TEST - is the angle entered correctly?
    ; Lead in message
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, str_angle_display
    mov rdx, 13
    syscall

    ; Display angle
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, chr_array_angle
    mov rdx, size_str_angle
    syscall

    ; Newline
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, str_newline
    mov rdx, 3
    syscall

; 4) CONVERT STRING TO FLOAT

    ; Convert angle string to float - THIS DOESN'T WORK, everythig else might be fine
    ; but nothing is getting stored into xmm0 or xmm8 as far as I can tell, thus the constant
    ; 0 return.
    mov rax, 0
    mov rdi, chr_array_angle
    call scan
    mov r15, rax ;r15 now has len(chr_array_angle)

    mov rax, 0
    mov rdi, chr_array_angle
    mov rsi, r15
    call atof
    movsd xmm8, xmm0
      
    ; degrees to radians
    mov rbx, 180
    cvtsi2sd xmm10, rbx
    mov rax, 0x400921FB54442D18
    push rax
    movsd xmm9, [rsp]
    pop rax

    mulsd xmm8, xmm9
    divsd xmm8, xmm10

    ; convert radian float to string
    mov rax, 1
    movsd xmm0, xmm8
    mov rdi, chr_array_radians
    mov rsi, size_str_radians
    call ftoa
    mov r12, rax

    ; display radian string
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, chr_array_radians
    mov rdx, r12
    syscall



; 2B) DISPLAY END TIME IN TICS

    ; 0 out rdx and rdx
    mov rax, 0
    mov rdx, 0

    ; Get current tic count and store in rdx and rax
    cpuid           ; Pause system clock
    rdtsc           ; Store system clock time into rax and rdx
    shl rdx, 32     ; Bitshift rdx 32 bits left 
    or rdx, rax     ; All 64 bits in rdx

    ; Convert time stamp rdx into string 
    mov rax, 0
    mov rdi, rdx                ; rdi = 64 bit integer to be converted into a string
    mov rsi, chr_array_clock    ; rsi = starting address of the string that will recieve the converted integer
    call itoa
    mov r15, chr_array_clock

    ; Display chr_array_clock
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, str_time1
    mov rdx, 17
    syscall

    mov rax, sys_write
    mov rdi, stdout
    mov rsi, chr_array_clock
    mov rdx, size_str_clock
    syscall

    mov rax, sys_write
    mov rdi, stdout
    mov rsi, str_time2
    mov rdx, 6
    syscall




; 1B) GOODBYE MESSAGE AND TERMINATION

    ; Display goodbye message
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, str_goodbye
    mov rdx, 23
    syscall

    ; Terminate
    mov rax, sys_terminate
    mov rdi, exit_with_success
    syscall


; -) Display time (in tics) to complete
; -) Enter and display angle
; -) Convert and display radians
; -) Cosine function
; -) subract final time from initial time to get total time (bonus)

