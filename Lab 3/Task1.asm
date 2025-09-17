; Scan two variables a and b. Print the value of their GCD

extern printf
extern scanf

SECTION .data
    x:      dq 0
    y:      dq 1

    prompt: db "Enter two numbers: ",0
    in_fmt: db "%ld",0
    out_fmt: db "GCD value: %ld",10,0
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

gcd_loop:

    mov rax, [y]
    cmp rax, 0
    je gcd_exit     ; exit loop if b==0

    mov rcx, rax    ; rcx = y
    mov rax, [x]    ; rax = x
    cqo
    idiv rcx        ; x/y , remainder in rdx

    mov [x], rcx
    mov [y], rdx
    jmp gcd_loop



gcd_exit:

    mov rdi, out_fmt
    mov rsi, [x]
    mov rax, 0
    call printf

    pop rbp
    mov rax, 0
    ret
