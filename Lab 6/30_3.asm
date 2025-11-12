extern scanf
extern printf
extern malloc
extern free

section .data
    fmt_int    db "%d", 0
    fmt_float  db "%.2f", 10, 0
    fmt_zero   db "0", 10, 0

section .bss
    n           resd 1
    threshold   resd 1

section .text
    global main

main:
    ; prologue - align stack for calls
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; read n and threshold
    lea rdi, [rel fmt_int]
    lea rsi, [rel n]
    xor eax, eax
    call scanf

    lea rdi, [rel fmt_int]
    lea rsi, [rel threshold]
    xor eax, eax
    call scanf

    ; load n into r13 (64-bit)
    mov eax, dword [rel n]
    test eax, eax
    jle .exit_zero      ; if n <= 0 exit
    mov r13, rax        ; r13 = n

    ; size = n * 4 (size of int)
    mov rax, r13
    shl rax, 2          ; rax = n * 4
    mov rdi, rax        ; malloc(size)
    call malloc
    test rax, rax
    je .exit_zero       ; malloc failed
    mov r12, rax        ; r12 = base pointer to array (preserve in callee-saved)

    ; loop read elements: for i = 0..n-1: scanf("%d", &arr[i])
    xor rbx, rbx        ; i = 0
.read_loop:
    cmp rbx, r13
    jae .after_read
    ; compute address &arr[i] -> rsi
    lea rsi, [r12 + rbx*4]
    lea rdi, [rel fmt_int]
    xor eax, eax
    call scanf
    inc rbx
    jmp .read_loop
.after_read:

    ; compute sum and count of elements > threshold
    xor r14d, r14d      ; r14d = sum (32-bit int)
    xor r15d, r15d      ; r15d = count (32-bit int)
    mov rbx, 0          ; rbx = loop counter

.sum_loop:
    cmp rbx, r13
    jae .after_sum

    ; load arr[rbx]
    mov eax, dword [r12 + rbx*4]
    mov ecx, dword [rel threshold]
    
    ; compare arr[rbx] > threshold
    cmp eax, ecx
    jle .not_above      ; if arr[rbx] <= threshold, skip

    ; add to sum and increment count
    add r14d, eax       ; sum += arr[rbx]
    inc r15d            ; count++

.not_above:
    inc rbx
    jmp .sum_loop

.after_sum:
    ; if count == 0, print 0 and exit
    test r15d, r15d
    jz .print_zero

    ; compute average: sum / count (as floating point)
    ; convert sum and count to double for floating point division
    ; use xmm registers for FPU operations
    
    ; convert r14d (sum) to double in xmm0
    cvtsi2sd xmm0, r14d  ; xmm0 = (double)sum

    ; convert r15d (count) to double in xmm1
    cvtsi2sd xmm1, r15d  ; xmm1 = (double)count

    ; compute average = xmm0 / xmm1
    divsd xmm0, xmm1     ; xmm0 = sum / count

    ; print average with printf("%.2f\n", average)
    ; In System V ABI, XMM0 is used for floating point arguments
    lea rdi, [rel fmt_float]
    ; xmm0 is already set
    mov eax, 1          ; al = 1 (one XMM arg)
    call printf

    jmp .exit_free

.print_zero:
    ; print 0
    lea rdi, [rel fmt_zero]
    xor eax, eax
    call printf

.exit_free:
    ; free(array)
    mov rdi, r12
    call free

.exit_zero:
    ; epilogue
    add rsp, 16
    pop rbp
    mov eax, 0
    ret
