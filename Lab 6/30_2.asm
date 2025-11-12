extern scanf
extern printf
extern malloc
extern free

section .data
    fmt_int    db "%d", 0
    fmt_out    db "%d", 10, 0 

section .bss
    n           resd 1
    k           resd 1

section .text
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16          ; align to 16 bytes

    ; read n and k
    lea rdi, [rel fmt_int]
    lea rsi, [rel n]
    xor eax, eax
    call scanf

    lea rdi, [rel fmt_int]
    lea rsi, [rel k]
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

    ; compute effective rotation: k_eff = k % n
    mov eax, dword [rel k]
    xor edx, edx        ; clear edx for unsigned division
    mov ecx, dword [rel n]
    test ecx, ecx
    jz .exit_free       ; if n == 0, exit
    div ecx             ; eax = eax / ecx, edx = eax % ecx
    mov r14d, edx       ; r14d = k % n (effective rotation)
    test r14d, r14d
    je .exit_free       ; if k_eff == 0, just exit (array unchanged)

    ; rotate right by r14d positions
    ; For right rotation by k: element at index i goes to index (i+k) % n
    ; So to print in rotated order: print element at index (n - k_eff + i) % n for i = 0..n-1
    ; Simpler: start at index (n - k_eff) and print n elements wrapping around
    
    ; start_idx = (n - k_eff) % n = n - k_eff (since k_eff < n)
    mov eax, dword [rel n]
    sub eax, r14d       ; eax = n - k_eff
    mov r15d, eax       ; r15d = start index
    xor rbx, rbx        ; rbx = loop counter (0..n-1)

.print_loop:
    cmp rbx, r13
    jae .exit_free

    ; idx = (start_idx + rbx) % n
    mov eax, r15d
    add eax, ebx        ; eax = start_idx + rbx
    xor edx, edx        ; clear edx for unsigned division
    mov ecx, dword [rel n]
    div ecx             ; edx = remainder = (start_idx + rbx) % n
    mov ecx, edx        ; ecx = (start_idx + rbx) % n

    ; print arr[idx]
    mov eax, dword [r12 + rcx*4]
    lea rdi, [rel fmt_out]
    mov esi, eax
    xor eax, eax
    call printf

    inc rbx
    jmp .print_loop

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
