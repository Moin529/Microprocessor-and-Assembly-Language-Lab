extern      printf
extern      scanf

SECTION .data
int_in_fmt :    db "%ld", 0
int_out_fmt :   db "Sum = %ld", 10, 0
prompt1 :       db "Enter first number : ", 0
prompt2 :       db "Enter second number : ", 0


SECTION .bss
num1:    resq    1
num2:    resq    1


SECTION .text
global main

;rdi = num1, rsi = num2
sum:
    mov rax, rdi
    add rax, rsi
    ret

main:
    push rbp

    mov rdi, prompt1
    mov rax, 0
    call printf

    mov rdi, int_in_fmt
    mov rsi, num1
    mov rax, 0
    call scanf

    mov rdi, prompt2
    mov rax, 0
    call printf

    mov rdi, int_in_fmt
    mov rsi, num2
    mov rax, 0
    call scanf

    mov rdi, [num1]
    mov rsi, [num2]
    call sum

    mov rdi, int_out_fmt
    mov rsi, rax
    mov rax, 0
    call printf

    mov rax, 0
    pop rbp
    ret