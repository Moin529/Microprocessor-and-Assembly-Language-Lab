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

; Node structure:
; offset 0: value (8 bytes)
; offset 8: left pointer (8 bytes)
; offset 16: right pointer (8 bytes)
; Total: 24 bytes per node

main:
    ; Read all input at once
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, input_buffer
    mov rdx, 1048576
    syscall
    
    ; Parse N from input_buffer
    mov rsi, input_buffer
    call parse_int
    mov [n], rax
    
    ; Initialize root to NULL
    mov qword [root], 0
    
    ; Read and insert N integers
    mov rcx, [n]
    
insert_loop:
    cmp rcx, 0
    je done_inserting
    push rcx
    
    ; Parse next integer
    call parse_int
    
    ; Insert into BST
    mov rdi, rax            ; value to insert
    call insert_node
    
    pop rcx
    dec rcx
    jmp insert_loop
    
done_inserting:
    ; Perform inorder traversal
    mov rdi, [root]
    call inorder_traversal
    
    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    ; Return 0
    xor rax, rax
    ret

; Parse integer from input_buffer at rsi
; Returns integer in rax, updates rsi
parse_int:
    push rbx
    push rcx
    push rdx
    
    ; Skip whitespace
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
    xor rax, rax            ; result = 0
    xor rbx, rbx            ; sign = 0 (positive)
    
    ; Check for negative sign
    movzx rcx, byte [rsi]
    cmp cl, '-'
    jne .parse_digits
    mov rbx, 1              ; sign = 1 (negative)
    inc rsi
    
.parse_digits:
    movzx rcx, byte [rsi]
    
    ; Check if digit
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
    ; Apply sign
    cmp rbx, 1
    jne .return
    neg rax
    
.return:
    pop rdx
    pop rcx
    pop rbx
    ret

; Allocate memory for a new node
; Returns pointer in rax
allocate_node:
    push rdi
    push rsi
    push rdx
    
    mov rax, 9              ; sys_mmap
    xor rdi, rdi            ; addr = NULL
    mov rsi, 24             ; length = 24 bytes
    mov rdx, 3              ; prot = PROT_READ | PROT_WRITE
    mov r10, 34             ; flags = MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1              ; fd = -1
    xor r9, r9              ; offset = 0
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    ret

; Insert value (rdi) into BST
; Uses root pointer
insert_node:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    mov r12, rdi            ; r12 = value to insert
    
    ; Allocate new node
    call allocate_node
    mov r13, rax            ; r13 = new node pointer
    
    ; Initialize new node
    mov [r13], r12          ; node->value = value
    mov qword [r13 + 8], 0  ; node->left = NULL
    mov qword [r13 + 16], 0 ; node->right = NULL
    
    ; Check if tree is empty
    cmp qword [root], 0
    jne .tree_not_empty
    
    ; Tree is empty, set root
    mov [root], r13
    jmp .done
    
.tree_not_empty:
    ; Traverse to find insertion point
    mov rbx, [root]         ; rbx = current node
    
.traverse:
    mov rax, [rbx]          ; rax = current->value
    
    cmp r12, rax
    jl .go_left
    
.go_right:
    ; Check if right child exists
    cmp qword [rbx + 16], 0
    jne .right_exists
    
    ; Insert as right child
    mov [rbx + 16], r13
    jmp .done
    
.right_exists:
    mov rbx, [rbx + 16]
    jmp .traverse
    
.go_left:
    ; Check if left child exists
    cmp qword [rbx + 8], 0
    jne .left_exists
    
    ; Insert as left child
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

; Inorder traversal of BST rooted at rdi
inorder_traversal:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    
    ; Check if node is NULL
    cmp rdi, 0
    je .done
    
    mov rbx, rdi            ; rbx = current node
    
    ; Traverse left subtree
    mov rdi, [rbx + 8]
    call inorder_traversal
    
    ; Print current node value
    mov rdi, [rbx]
    call print_int
    
    ; Print space
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
    
    ; Traverse right subtree
    mov rdi, [rbx + 16]
    call inorder_traversal
    
.done:
    pop r12
    pop rbx
    pop rbp
    ret

; Print integer in rdi
print_int:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    
    mov rax, rdi
    mov r12, buffer + 19    ; r12 = end of buffer
    mov byte [r12], 0       ; null terminator
    dec r12
    
    ; Handle zero
    cmp rax, 0
    jne .check_negative
    mov byte [r12], '0'
    jmp .print
    
.check_negative:
    xor r13, r13            ; r13 = 0 (not negative)
    cmp rax, 0
    jge .convert
    
    ; Negative number
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
    
    ; Add negative sign if needed
    cmp r13, 1
    jne .print
    mov byte [r12], '-'
    dec r12
    
.print:
    inc r12                 ; adjust to first character
    
    ; Calculate length
    mov rbx, buffer + 19
    sub rbx, r12
    
    ; Write to stdout
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, r12
    mov rdx, rbx
    syscall
    
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret