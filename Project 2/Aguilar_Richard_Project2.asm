#Name: Richard Aguilar

.data
	numArray: .word 0x3F, 0x6, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x7, 0x7F, 0x6F
	a: .word 0
	b: .word 20
.text
	lw $t1, a
	lw $t2, b
	la $t3, 0xFFFF0011 #Address of left LED
	la $t4, 0xFFFF0010 #Address of right LED
	slt $s0, $t1, $zero
	beq $s0, 1, Exit #Checks to see if lower bound is less than zero. If it is, exit
	slti $s0, $t2, 100
	bne $s0, 1, Exit #Checks if upper bound is less than 100. If it is not, exit
	beq $t1, $t2, main #Checks if a and b are equal to each other. If they are, continue to main
	slt $s0, $t1, $t2
	bne $s0, 1, Exit #Checks if a is less than b. If it is not, Exit
	
	main:
	addi $s0, $zero, 10
	la $t5, numArray #load address of number array for left digit
	la $t6, numArray #load address of number array for right digit
	div $t1, $s0 #This is done to determine what the first number printed shall be
	mflo $s1#initial quotient
	mfhi $s2#inital remainder
	addi $s3, $t2, 1 #This will be the ending condition, b + 1
	sll $s1, $s1, 2 #shift the left digit to correspond to array index
	sll $s2, $s2, 2 #shift the right digit to correspond to array index
	add $t5, $t5, $s1 #get the index for left digit
	add $t6, $t6, $s2 #get the index for left digit
	lw $a0, 0($t5) #Load value of index for left digit
	lw $a1, 0($t6) #Load value of index for right digit

	jal display
		OuterLoop:
		addi $t7, $zero, 0
			delayLoop: #this delay loop is meant to create a 1-2 second delay between sequential numbers
			addi $t7, $t7, 1
			bne $t7, 350000, delayLoop 
			InnerLoop:
			addi $s2, $s2, 4 #Increment the index in array for the right LED by one
			addi $t1, $t1, 1 #This increments the counter
			beq $t1, $s3, Exit #if counter reaches the ending value, exit
			beq $s2, 40, resetToZero #This checks if the second digit has reached 10
			add $t6, $t6, 4
			lw $a1, 0($t6)
			
			jal display
			move $t7, $zero
			j delayLoop
			
		continue:
		la $t6, numArray #Reset the address to the zeroth index for right digit
		lw $a1, 0($t6)
		add $t5, $t5, 4 #Increment left digit by one
		lw $a0, 0($t5)
		jal display
		j OuterLoop

		resetToZero:
		la $t6, numArray
		addi $s2, $zero, 0 #Resets the index in array for the right LED back to zero and jumps to outer loop
		j continue
		
		display:
		sb $a0, 0($t3) #display left digit
		sb $a1, 0($t4) #display right digit
		jr $ra
	
	Exit:
	li $v0, 10
	syscall
