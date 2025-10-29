section .data
    prompt_name     db "Enter student name: ", 0
    prompt_score1   db "Enter score 1: ", 0
    prompt_score2   db "Enter score 2: ", 0
    prompt_score3   db "Enter score 3: ", 0

    result_msg      db 10, "Student: %s", 10, "Average: %.2f", 10, "Grade: %c", 10, 0
    fmt_str         db "%s", 0
    fmt_int         db "%d", 0

    pass_char       db 'P', 0
    fail_char       db 'F', 0

section .bss
    name   resb 32
    score1 resd 1
    score2 resd 1
    score3 resd 1
    avg    resq 1
    grade  resb 1

section .rodata
    const3  dq 3.0
    const50 dq 50.0

section .text
    extern printf, scanf
    global main

main:
    push rbp
    mov rbp, rsp

    ; Input name
    lea rdi, [rel prompt_name]
    xor eax, eax
    call printf

    lea rsi, [rel name]
    lea rdi, [rel fmt_str]
    xor eax, eax
    call scanf

    ; Input score 1
    lea rdi, [rel prompt_score1]
    xor eax, eax
    call printf

    lea rsi, [rel score1]
    lea rdi, [rel fmt_int]
    xor eax, eax
    call scanf

    ; Input score 2
    lea rdi, [rel prompt_score2]
    xor eax, eax
    call printf

    lea rsi, [rel score2]
    lea rdi, [rel fmt_int]
    xor eax, eax
    call scanf

    ; Input score 3
    lea rdi, [rel prompt_score3]
    xor eax, eax
    call printf

    lea rsi, [rel score3]
    lea rdi, [rel fmt_int]
    xor eax, eax
    call scanf

    ; Compute average
    cvtsi2sd xmm0, dword [score1]    ; xmm0 = score1
    cvtsi2sd xmm1, dword [score2]    ; xmm1 = score2
    addsd xmm0, xmm1                 ; xmm0 += score2
    cvtsi2sd xmm1, dword [score3]    ; xmm1 = score3
    addsd xmm0, xmm1                 ; xmm0 += score3

    movsd xmm1, [rel const3]
    divsd xmm0, xmm1
    movsd [avg], xmm0

    movsd xmm1, [rel const50]
    comisd xmm0, xmm1
    ja  .pass
    mov al, [fail_char]
    jmp .store_grade
.pass:
    mov al, [pass_char]

.store_grade:
    mov [grade], al

    movzx edx, byte [grade]
    movsd xmm0, [avg]
    lea rsi, [rel name]
    lea rdi, [rel result_msg]
    mov eax, 1
    call printf

    mov eax, 0
    leave
    ret
