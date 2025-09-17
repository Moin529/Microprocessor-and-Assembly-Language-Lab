extern printf
extern scanf

SECTION .data
    x:      dq 0

    prompt: db "Enter a number: ",0
    in_fmt: db "%ld",0
    prime_txt: db "%ld is prime",10,0
    notprime_txt: db "%ld is not prime",10,0
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

    mov rax, [x]    

    cmp rax, 1
    jle not_prime
    
    cmp rax, 2
    je is_prime

    mov rcx, 2      ; i=2

check_loop:
    cmp rcx, rax
    jge is_prime

    mov rdx, 0
    mov rbx, rcx
    mov rax, [x]
    div rbx
    cmp rdx, 0
    je not_prime

    inc rcx
    jmp check_loop


not_prime:
    mov rdi, notprime_txt
    mov rsi, [x]
    mov rax, 0
    call printf
    jmp end_program


is_prime:
    mov rdi, prime_txt
    mov rsi, [x]
    mov rax, 0
    call printf
    jmp end_program


end_program:
    pop rbp
    mov rax, 0
    ret
