extern scanf
extern printf
extern qsort
extern malloc
extern free

section .data
	fmt_int    db "%d", 0
	fmt_out    db "%d %d", 10, 0

section .bss
	n           resd 1

section .text
	global main

comparator:
	; a -> rdi, b -> rsi
	mov eax, dword [rdi]
	mov edx, dword [rsi]
	sub eax, edx
	ret

main:
	push rbp
	mov rbp, rsp
	sub rsp, 16          ; align to 16 bytes

	; read n
	lea rdi, [rel fmt_int]
	lea rsi, [rel n]
	xor eax, eax        ; al = 0 for varargs ABI requirement
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

	; call qsort(base, nmemb, size, comparator)
	mov rdi, r12        ; base
	mov rsi, r13        ; nmemb
	mov rdx, 4          ; size
	lea rcx, [rel comparator]
	call qsort

	; if n == 0 nothing to print (we already handled <=0), but check
	cmp r13, 0
	je .free_and_exit

	; frequency counting on sorted array
	; r12 = base, r13 = n
	; load current = arr[0]
	mov eax, dword [r12]
	mov r14d, eax       ; current value
	mov r15d, 1         ; count = 1
	mov rbx, 1          ; i = 1
.freq_loop:
	cmp rbx, r13
	jae .print_last
	mov eax, dword [r12 + rbx*4]
	cmp eax, r14d
	je .inc_count

	; print current and count
	lea rdi, [rel fmt_out]
	mov esi, r14d       ; first int
	mov edx, r15d       ; second int
	xor eax, eax        ; al = 0 for varargs
	call printf

	; set current = element at index rbx (reload from memory)
	mov eax, dword [r12 + rbx*4]
	mov r14d, eax
	mov r15d, 1
	inc rbx
	jmp .freq_loop
    
.inc_count:
	inc r15d
	inc rbx
	jmp .freq_loop

.print_last:
	lea rdi, [rel fmt_out]
	mov esi, r14d
	mov edx, r15d
	xor eax, eax
	call printf

.free_and_exit:
	mov rdi, r12
	call free

.exit_zero:
	add rsp, 16
	pop rbp
	mov eax, 0
	ret

