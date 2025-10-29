extern    printf        
extern    scanf        

SECTION .data        
int_in_fmt:     db  "%ld",0
int_out_fmt:    db  "%ld",10,0
int:            dq  0
out_str_fmt:    db  "%s",10,0
in_str_fmt:     db  "%s",0

s1:     db  "Palindrome",0
s2:     db  "Not palindrome",0

SECTION .bss
str:    resb 100
arr:    resq 100
s:      resb 100

SECTION .text

global main        
main:                
    push rbp    
   
    call scan_str    ;scans string
    mov rsi,str
    mov rdi,s
    call str_copy
    mov rsi,s
   
    call str_len    ;get string length
    dec rcx
   
    lop:        ;iterate through all characters and convert all to uppercase
    cmp rcx,0
    jl dne
    add rsi,rcx
    mov al,[rsi]
    cmp al,'Z'    ;check lowercase
    jle cap
    sub al,'a'    ;convert if uppercase
    add al,'A'
    cap:
    mov [rsi],al
    sub rsi,rcx
    dec rcx
    jmp lop
    dne:
   
    mov rsi,s
    call str_len    ;gets string length
   
    mov rbx,1
    mov rdx,0
    dec rcx
   
    lop2:        ;while(i<=j){i++;j--;}
    cmp rdx,rcx
    jg dne2
   
    add rsi,rdx
    mov al,[rsi]    ;get s[i]
    sub rsi,rdx
   
    add rsi,rcx
    mov ah,[rsi]    ;get s[j]
    sub rsi,rcx
   
    cmp al,ah
    je eq
    mov rbx,0    ;if(s[i]!=s[j]) rbx = 0
    eq:
   
    inc rdx
    dec rcx
    jmp lop2
    dne2:
   
    cmp rbx,0
    je np
    mov rsi,s1    ;if(rbx!=0) print "Palindrome"
    call print_str
    jmp en
    np:
    mov rsi,s2    ;if(rbx==0) print "Not palindrome"
    call print_str
    en:
       
    mov rax,0
    pop rbp
    ret
   

;copy string pointed by rsi to rdi
str_copy:
    push rcx
    push rsi
    push rdi
    push rax
    call str_len
    lop_str_copy:
        cmp rcx,0
        jl dne_str_copy
        mov al,[rsi]
        mov [rdi],al
        add rsi,1
        add rdi,1
        sub rcx,1
        jmp lop_str_copy
   
    dne_str_copy:
    pop rax
    pop rdi
    pop rsi
    pop rcx
    ret

;returns string pointed by rsi length on rcx    
str_len:
    push rax
    push rsi
    mov rcx,0
    lop_str_len:
        mov al,[rsi]
        cmp al,0
        je dne_str_len
        add rsi,1
        add rcx,1
        jmp lop_str_len
    dne_str_len:
    pop rsi
    pop rax
    ret
   
;scan string and put it on str
scan_str:
    push rdx
    push rcx
    push rax
    push rdi
    push rsi
    mov rax, 0
    mov rdi, in_str_fmt
    mov rsi, str
    call scanf
    pop rsi
    pop rdi
    pop rax
    pop rcx
    pop rdx
    ret    
    
;print str(string) pointed by rsi    
print_str:
    push rdx
    push rcx
    push rax
    push rdi
    push rsi
    mov    rdi,out_str_fmt                
    mov    rax,0        
    call printf
    pop rsi
    pop rdi
    pop rax
    pop rcx
    pop rdx    
    ret
