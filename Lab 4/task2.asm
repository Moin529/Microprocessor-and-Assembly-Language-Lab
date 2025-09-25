extern printf
extern scanf

section .data
    prompt      db "Enter a number: ", 0
    in_fmt      db "%ld", 0
    out_fmt     db "%ld × %ld = %ld", 10, 0

section .text
global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    push rbx
    push r12
    push r13
    push r14

    mov rdi, prompt
    xor rax, rax
    call printf

    mov rdi, in_fmt
    lea rsi, [rbp - 8]
    xor rax, rax
    call scanf
    cmp rax, 1
    jne exit
    mov r12, [rbp - 8]

    mov r13, 1

mul_loop:
    cmp r13, 10
    jg exit

    mov rax, r12
    mul r13
    mov r14, rax

    mov rdi, out_fmt
    mov rsi, r12
    mov rdx, r13
    mov rcx, r14
    xor rax, rax
    call printf

    inc r13
    jmp mul_loop

exit:
    pop r14
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp

    mov rax, 0
    ret