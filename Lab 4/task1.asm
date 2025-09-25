extern printf
extern scanf

section .data
    prompt      db "Enter a number: ", 0
    in_fmt      db "%ld", 0
    out_fmt     db "Reversed number: %ld", 10, 0
    
section .bss
    n resq 1 ; Reserve a quadword (8 bytes) for the number

section .text
    global main

main:
    push rbp
    mov rbp, rsp

    mov rdi, prompt
    mov rax, 0
    call printf

    mov rax, 0
    mov rdi, in_fmt
    lea rsi, [n]
    call scanf

    mov rax, [n]
    xor rcx, rcx
    mov rbx, 10

reverse_loop:
    test rax, rax
    jz loop_done

    imul rcx, rcx, 10

    xor rdx, rdx 
    div rbx

    add rcx, rdx
    jmp reverse_loop

loop_done:

    mov rsi, rcx
    mov rdi, out_fmt
    mov rax, 0
    call printf

    mov rax, 0 
    pop rbp
    ret