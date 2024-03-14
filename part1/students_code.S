.global get_element_from_matrix, inner_prod, matrix_multiplication

# int get_element_from_matrix(int* matrix[], int n, int row, int col);
# Parameters:
# %rdi: int* matrix
# %esi: int n
# %edx: int row
# %ecx: int col
get_element_from_matrix:

    # (row, col) is stored at the index row * n + col
    movl    %edx, %eax             # Copy 'row' to %eax
    imull   %esi, %eax             # Calc row * n, store result in %eax
    addl    %ecx, %eax             # Add 'col' to %eax
    movl    (%rdi, %rax, 4), %eax  # Use %rax as an offset from 'matrix', move the value at that memory location to %eax
    ret                            # Return, with the result in %eax

# int inner_prod(int* mat_a[], int* mat_b[], unsigned int row_a, unsigned int col_b, unsigned int max_col_a, unsigned int max_col_b);
# Parameters:
# %rdi: int* mat_a
# %rsi: int* mat_b
# %edx: unsigned int row_a
# %ecx: unsigned int col_b
# %r8d:  unsigned int max_col_a
# %r9d:  unsigned int max_col_b
inner_prod:
    # Save callee-saved registers
    pushq   %rbx                   
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15

    xorl    %r10d, %r10d           # Clear %r10d to use as a counter
    xorl    %r11d, %r11d           # Clear %r11d to accumulate the sum

    # Save the parameters 1-4
    movq    %rdi, %r12             # Save mat_a in %r12
    movq    %rsi, %r13             # Save mat_b in %r13
    movl    %edx, %r14d            # Save row_a in %r14d
    movl    %ecx, %r15d            # Save col_b in %r15d

.inner_prod_loop:
    # Get the element from mat_a (the row is row_a, the column is %r10d)
    movq    %r12, %rdi             # Set 'mat_a' for get_element_from_matrix
    movl    %r8d, %esi             # Set 'n' for mat_a
    movl    %r14d, %edx            # Set 'row' for mat_a
    movl    %r10d, %ecx            # Set 'col' for mat_a
    call    get_element_from_matrix
    movl    %eax, %ebx             # Save the intermediate result

    # Get the element from mat_b (the row is %r10d, the column is col_b)
    movq    %r13, %rdi             # Set 'mat_b' for get_element_from_matrix
    movl    %r9d, %esi             # Set 'n' for mat_b
    movl    %r10d, %edx            # Set 'row' for mat_b
    movl    %r15d, %ecx            # Set 'col' for mat_b
    call    get_element_from_matrix

    imull   %ebx, %eax             # Multiply the results
    addl    %eax, %r11d            # Add to the sum

    incl    %r10d                  # Increment the counter
    cmpl    %r10d, %r8d            # Compare the counter with max_col_a
    jne     .inner_prod_loop       # If not equal, loop again

    movl    %r11d, %eax            # Move the sum to %eax

    # Restore callee-saved registers
    popq    %r15                   
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %rbx

    ret
      
# void set_element_in_matrix(int* matrix, unsigned int num_of_columns, unsigned int row, unsigned int col, int value);
# Parameters:
# %rdi: int* matrix
# %rsi: unsigned int num_of_columns
# %rdx: unsigned int row
# %rcx: unsigned int col
# %r8:  int value


# int matrix_multiplication(int* res[], int* mat_a[], int* mat_b[], unsignedint m, unsigned int n, unsigned int p, unsigned int q);
# Parameters:
# %rdi: int* res
# %rsi: int* mat_a
# %rdx: int* mat_b
# %ecx: unsigned int m
# %r8d:  unsigned int n
# %r9d:  unsigned int p
# unsigned int q - in memory
matrix_multiplication:
	cmp %r9d, %r8d       # compare n and p
	jne not_possible    # if not equal, return 0
	mov $1, %eax	    # else, return 1
	jmp .continue
	not_possible:
	mov $0, %eax
	ret
	

.continue:
	# Save callee-saved registers
	pushq   %r12

	#rbp available for use
	xorl    %r10d, %r10d             # Clear %r10d to use as a counter for rows of mat_a
	xorl	%r11d, %r11d             # Clear %r11d to use as a counter for columns of mat_b
	mov     16(%rsp), %r12d  		   # Move q from the stack to %r12d

.matrix_multiplication_outer_loop:
	xorl	%r11d, %r11d             # Reset the counter for columns of mat_b
.matrix_multiplication_inner_loop:
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	movq    %rsi, %rdi             # Set 'mat_a' for inner_prod
	movq    %rdx, %rsi             # Set 'mat_b' for inner_prod
	movl    %r10d, %edx            # Set 'row_a' for inner_prod
	movl    %r11d, %ecx            # Set 'col_b' for inner_prod
	movl    %r8d, %r8d             # Set 'max_col_a' for inner_prod
	movl    %r12d, %r9d            # Set 'max_col_b' for inner_prod
	call    inner_prod             # Call the helper function

	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
    
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11

	movq    %rdi, %rdi             # Set 'res' for set_element_in_matrix
	movl    %r12d, %esi            # Set 'num_of_columns' for set_element_in_matrix
	movl    %r10d, %edx            # Set 'row' for set_element_in_matrix
	movl    %r11d, %ecx            # Set 'col' for set_element_in_matrix
	movl    %eax, %r8d             # Set 'value' for set_element_in_matrix
	call    set_element_in_matrix  # Call the helper function

	pop %r11
	pop %r10
	pop %r9
	pop %r8
	pop %rcx
	pop %rdx
	pop %rsi
	pop %rdi

	incl   %r11d                   # Increment the counter for columns of mat_b
	cmpl    %r11d, %r12d           # Compare the counter with q
	jne    .matrix_multiplication_inner_loop       # If not equal, loop again
	incl    %r10d 				    # Increment the counter for rows of mat_a
	cmpl    %r10d, %ecx            # Compare the counter with m 
	jne    .matrix_multiplication_outer_loop       # If not equal, loop again

	# Restore callee-saved registers
       popq    %r12
	
	ret

