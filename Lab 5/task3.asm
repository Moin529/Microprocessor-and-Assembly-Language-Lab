extern    printf        
extern    scanf        

SECTION .data        
in_str_fmt:     db  "%s", 0
out_str_fmt:    db  "%s", 10, 0
prompt:         db  "Enter a string: ", 0
result_msg:     db  "Reversed string: ", 0

SECTION .bss
str:    resb    100
rev:    resb    100

SECTION .text
global main        

; rsi = string pointer
; rcx = length
str_len:
    push rax
    push rsi
    mov rcx, 0
str_len_loop:
    mov al, [rsi]
    cmp al, 0
    je str_len_done
    inc rcx
    inc rsi
    jmp str_len_loop
str_len_done:
    pop rsi
    pop rax
    ret

; rdi = source string, rsi = destination string
reverse_str:
    push rax
    push rcx
    push rsi
    push rdi
    push rdx

    mov rdx, rsi
    mov rsi, rdi
    call str_len
    mov rdi, rdx
    
    dec rcx
    mov rdx, rcx
    
reverse_loop:
    cmp rcx, 0
    jl reverse_done
    
    add rsi, rcx
    mov al, [rsi]
    sub rsi, rcx
    
    mov [rdi], al
    inc rdi
    dec rcx
    jmp reverse_loop

reverse_done:
    mov byte [rdi], 0
    
    pop rdx
    pop rdi
    pop rsi
    pop rcx
    pop rax
    ret

main:                
    push rbp
    
    ; Print prompt
    mov rdi, prompt
    mov rax, 0
    call printf
    
    ; Read string
    mov rdi, in_str_fmt
    mov rsi, str
    mov rax, 0
    call scanf
    
    ; Print result message
    mov rdi, result_msg
    mov rax, 0
    call printf
    
    ; Call reverse_str function
    mov rdi, str
    mov rsi, rev
    call reverse_str
    
    ; Print reversed string
    mov rdi, out_str_fmt
    mov rsi, rev
    mov rax, 0
    call printf
    
    mov rax, 0
    pop rbp
    ret
