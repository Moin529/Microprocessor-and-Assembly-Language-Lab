extern printf
extern scanf

section .data
    x:          dq 0

    prompt      db "Enter a number: ", 0
    in_fmt      db "%ld", 0
    out_fmt     db "%ld", 10, 0
    str_fmt     db "%s" , 0

section .text
    global main

main:
    push rbp
    mov rbp, rsp

    mov rax, 0
    mov rdi, str_fmt
    mov rsi, prompt
    call printf

    mov rax, 0
    mov rdi, in_fmt
    mov rsi, x
    call scanf

    mov r12, [x]
    mov r13, 1 

loop:
    cmp r13, r12
    jg end_loop

    mov rax, r12
    mov rdx, 0
    div r13

    cmp rdx, 0
    jne not_divisor

    mov rsi, r13
    mov rdi, out_fmt
    mov rax, 0
    call printf

not_divisor:
    inc r13
    jmp loop

end_loop:
    mov rax, 0
    pop rbp
    ret