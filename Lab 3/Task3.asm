extern printf
extern scanf

SECTION .data
    x:      dq 0
    y:      dq 1
    z:      dq 2
    max:    dq 3

    prompt: db "Enter three numbers: ",0
    in_fmt: db "%ld",0
    out_fmt: db "Maximum value: %ld",10,0
    str_fmt: db "%s",0

SECTION .text
    global main

main:
    
    push rbp

    mov rax, 0
    mov rdi, str_fmt
    mov rsi, prompt
    call printf

    mov rax, 0
    mov rdi, in_fmt
    mov rsi, x
    call scanf

    mov rax, 0
    mov rdi, in_fmt
    mov rsi, y
    call scanf

    mov rax, 0
    mov rdi, in_fmt
    mov rsi, z
    call scanf

    ; max = x
    mov rax, [x]
    mov [max], rax

    ; if y > max then, max = y
    mov rax, [y]
    cmp rax, [max]
    jle skip_y
    mov [max], rax

skip_y:
    ; if z > max then, max = z
    mov rax, [z]
    cmp rax, [max]
    jle skip_z
    mov [max], rax

skip_z:
    mov rdi, out_fmt
    mov rsi, [max]
    mov rax, 0
    call printf

    pop rbp
    mov rax, 0
    ret




