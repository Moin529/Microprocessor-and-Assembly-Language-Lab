section .data
    space db ' ', 0
    newline db 10, 0

section .bss
    n resq 1
    root resq 1
    buffer resb 20
    input_buffer resb 1048576
    
section .text
    global main

main:
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 1048576
    syscall
    
    mov rsi, input_buffer
    call parse_int
    mov [n], rax
    mov qword [root], 0
    mov rcx, [n]
    
insert_loop:
    cmp rcx, 0
    je done_inserting
    push rcx
    call parse_int
    mov rdi, rax
    call insert_node
    pop rcx
    dec rcx
    jmp insert_loop
    
done_inserting:
    mov rdi, [root]
    call inorder_traversal
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    xor rax, rax
    ret

parse_int:
    push rbx
    push rcx
    push rdx
    
.skip_space:
    movzx rax, byte [rsi]
    cmp al, ' '
    je .next_char
    cmp al, 10
    je .next_char
    cmp al, 13
    je .next_char
    cmp al, 9
    je .next_char
    jmp .start_parse

.next_char:
    inc rsi
    jmp .skip_space
    
.start_parse:
    xor rax, rax
    xor rbx, rbx
    movzx rcx, byte [rsi]
    cmp cl, '-'
    jne .parse_digits
    mov rbx, 1
    inc rsi
    
.parse_digits:
    movzx rcx, byte [rsi]
    cmp cl, '0'
    jb .done_parse
    cmp cl, '9'
    ja .done_parse
    
    ; result = result * 10 + (digit - '0')
    imul rax, 10
    sub cl, '0'
    movzx rdx, cl
    add rax, rdx
    
    inc rsi
    jmp .parse_digits
    
.done_parse:
    cmp rbx, 1
    jne .return
    neg rax
    
.return:
    pop rdx
    pop rcx
    pop rbx
    ret

allocate_node:
    push rdi
    push rsi
    push rdx
    
    mov rax, 9
    xor rdi, rdi
    mov rsi, 24
    mov rdx, 3
    mov r10, 34
    mov r8, -1
    xor r9, r9
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    ret

insert_node:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    mov r12, rdi

    call allocate_node
    mov r13, rax
    mov [r13], r12
    mov qword [r13 + 8], 0
    mov qword [r13 + 16], 0
    
    cmp qword [root], 0
    jne .tree_not_empty
    
    mov [root], r13
    jmp .done
    
.tree_not_empty:
    mov rbx, [root]
    
.traverse:
    mov rax, [rbx]
    cmp r12, rax
    jl .go_left
    
.go_right:
    cmp qword [rbx + 16], 0
    jne .right_exists
    mov [rbx + 16], r13
    jmp .done
    
.right_exists:
    mov rbx, [rbx + 16]
    jmp .traverse
    
.go_left:
    cmp qword [rbx + 8], 0
    jne .left_exists
    mov [rbx + 8], r13
    jmp .done
    
.left_exists:
    mov rbx, [rbx + 8]
    jmp .traverse
    
.done:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

inorder_traversal:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    cmp rdi, 0
    je .done
    
    mov rbx, rdi
    mov rdi, [rbx + 8]
    call inorder_traversal
    
    mov rdi, [rbx]
    call print_int
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
    
    mov rdi, [rbx + 16]
    call inorder_traversal
    
.done:
    pop r12
    pop rbx
    pop rbp
    ret

print_int:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    mov rax, rdi
    mov r12, buffer + 19
    mov byte [r12], 0
    dec r12
    
    cmp rax, 0
    jne .check_negative
    mov byte [r12], '0'
    jmp .print
    
.check_negative:
    xor r13, r13
    cmp rax, 0
    jge .convert
    mov r13, 1
    neg rax
    
.convert:
    xor rdx, rdx
    mov rbx, 10
    div rbx                 ; rax = rax / 10, rdx = rax % 10
    add dl, '0'
    mov [r12], dl
    dec r12
    
    cmp rax, 0
    jne .convert
    
    cmp r13, 1
    jne .print
    mov byte [r12], '-'
    dec r12
    
.print:
    inc r12
    mov rbx, buffer + 19
    sub rbx, r12
    
    mov rax, 1
    mov rdi, 1
    mov rsi, r12
    mov rdx, rbx
    syscall
    
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret