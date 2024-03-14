.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
  ####### Some smart student's code here #######
	pushq 	%rax
	pushq 	%rbx
	pushq 	%rcx
	pushq 	%rdx	
	pushq 	%r8
	pushq 	%r9
	pushq 	%r10
	pushq 	%r11
	pushq 	%r12
	pushq 	%r13
	pushq 	%r14
	pushq 	%r15
	pushq 	%rsi
	pushq 	%rbp
	pushq 	%rsp

	movq	120(%rsp), %rbx      # Load the address of the return address
	movq 	(%rbx), %rbx         # Copy %rip value to %rbx
	cmpb	$0x0F, %bl      
	jne     one_byte             # If first byte is 0x0F, then it is a one-byte OP code
  
two_bytes:
	movb    %bh, %bl             # Move the higher byte to the lower byte of %rbx
	movq    %rbx, %rdi           # Copy the 2-byte OP code to %rdi (first parameter)
	call 	what_to_do
	cmp 	$0, %rax
	jne 	not_zero_two		 # If not 0 returned finish
	jmp 	zero				 # If returned 0 jump to the original handler

one_byte:
	movq    %rbx, %rdi           # Copy the 2-byte OP code to %rdi (first parameter)
	call	what_to_do
	cmpq	$0, %rax         
	jmp 	not_zero_one         # If not 0 returned finish

zero:
	popq 	%rsp
	popq 	%rbp
	popq 	%rsi
	popq 	%r15
	popq 	%r14
	popq 	%r13
	popq 	%r12
	popq 	%r11
	popq 	%r10
	popq 	%r9
	popq 	%r8
	popq 	%rdx
	popq 	%rcx
	popq 	%rbx
	popq 	%rax
	jmp 	* old_ili_handler
	jmp 	end

not_zero_one:
	movq 	%rax, %rdi
	popq 	%rsp
	popq 	%rbp
	popq 	%rsi
	popq 	%r15
	popq 	%r14
	popq 	%r13
	popq 	%r12
	popq 	%r11
	popq 	%r10
	popq 	%r9
	popq 	%r8
	popq 	%rdx
	popq 	%rcx
	popq 	%rbx
	popq 	%rax

	addq 	$1, (%rsp)
	jmp 	end

not_zero_two:
	popq 	%rsp
	popq 	%rbp
	popq 	%rsi
	popq 	%r15
	popq 	%r14
	popq 	%r13
	popq 	%r12
	popq 	%r11
	popq 	%r10
	popq 	%r9
	popq 	%r8
	popq 	%rdx
	popq 	%rcx
	popq 	%rbx
	popq 	%rax

	movq 	%rax, %rdi
	addq 	$2, (%rsp) 

end:
	iretq
  