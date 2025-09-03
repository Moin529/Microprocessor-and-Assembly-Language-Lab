extern  printf
extern  scanf

SECTION .data
    x:      dq 0
    sum:    dq 0

    prompt: db "Enter an integer x: ",0
    in_fmt: db "%ld",0
    out_fmt: db "Sum from 1 to %ld = %ld",10,0
    str_fmt: db "%s",0

SECTION .text
    global main

main:
    push rbp

    mov rax,0
    mov rdi,str_fmt
    mov rsi,prompt
    call printf

    mov rax,0
    mov rdi,in_fmt
    mov rsi,x
    call scanf


    mov rax,[x] 
    mov rbx,rax 
    add rbx,1
    imul rax,rbx 
    mov rcx,2
    cqo      
    idiv rcx 
    mov [sum],rax 

    mov rdi,out_fmt
    mov rsi,[x]
    mov rdx,[sum] 
    mov rax,0
    call printf

    pop rbp
    mov rax,0
    ret
