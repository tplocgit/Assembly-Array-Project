.data
path_FileIn:			.asciiz "input_sort.txt"
path_FileOut:		.asciiz "output_sort.txt"
str_Loading:		.asciiz "Loading from input_sort.txt...\n"
str_Saving:			.asciiz "Saving into output_sort.txt...\n"
str_Sorting:			.asciiz "Sorting...\n"
str_dataChecking	:	.asciiz "Pease Check data: "
str_space:			.asciiz " "
str_endl:			.asciiz "\n"
str_FileNotFound: 	.asciiz "Error XXX: File not found\n"
str_StringOfFileIn:	.asciiz "" 
itos_Buffer:			.space 12
.text
.globl main

# $s1 is n
# $s0 is array
# $s2 is file descriptor
# $s3 is a pointer point to current char read in file 
main:
	li $v0, 4
	la $a0, str_Loading
	syscall
	jal LoadArrayFromFile
	
	li $v0, 4
	la $a0, str_Sorting
	syscall
	#jal QuickSort	

	li $v0, 4
	la $a0, str_Saving
	syscall
	jal WriteArrayToFile
Endmain:
j Exit

LoadArrayFromFile:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	# Open file
	li $v0, 13 # $v0 = 13 for open file
	la $a0, path_FileIn # $a0 store path
	li $a1, 0 # Flag read only
	li $a2, 0 # mode is ignored
	syscall
	# Saving decriptor and checking error
	move $s2, $v0
	bgez $s2, NotError
	# Error part
	li $v0, 4
	la $a0, str_FileNotFound
	syscall
	j CloseFile
	
	NotError:
	# Read size
	li $v0, 14 # read file
	move $a0, $s2 # a0 = file decriptor
	la $a1, str_StringOfFileIn # adress of input
	li $a2, 12000
	syscall

	jal Parse

	CloseFile:
	li $v0, 16
	move $a0, $s2
	syscall
EndLoadArrayFromFile:
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

QuickSort:
EndQuickSort:
	jr $ra

Parse:
	addi $sp, $sp, -4 			# Request 4 bytes memory in stack to store return address
	sw $ra, 4($sp) 			# Store return address to stack
	la $s3, str_StringOfFileIn 	# Get a pointer to begin of string got from file
	move $t0, $s3			# Store first address to calculate number of chars read
	GetSizeLoop:
		lb $t1, ($s3)
		beq $t1, 10, EndGetSizeLoop	# if '\n' is read break 
		addi $s3, $s3, 1 				# else move to next char
		j GetSizeLoop
	EndGetSizeLoop:
 	addi $sp, $sp, -4			# Ask 4 bytes block to store start of line
	sw $t0, 4($sp)			# Store start of line
	jal StrToInt
	lw $s1, 4($sp)
	addi $sp, $sp, 4
	addi $s3, $s3, 1
	# Allocate memory
	li $t0, 4
	mul $a0, $s1, $t0 	# calc size
	li $v0, 9			# $v0, 9 to allocate memory
	syscall
	move $s0, $v0		# save address of array
	# Read element
	move $t0, $s3		# start line
	move $t2, $s0		# point to array
	GetElementLoop:
		lb $t1, ($s3)
		beq $t1, 32, StoreElement
		beq $t1, 10, EndGetElementLoop
		j PrepareNextLoop
		StoreElement:
			addi $sp, $sp, -4
			sw $t2, 4($sp)		# store before jal
			addi $sp, $sp, -4
			sw $t0, 4($sp)		# store to jal
			jal StrToInt
			
			lw $t1, 4($sp)
			add $sp, $sp, 4
			lw $t2, 4($sp)
			add $sp, $sp, 4
			sw $t1, ($t2)
			addi $t2, $t2, 4
			move $t0, $s3
			addi $t0, $t0,1
		PrepareNextLoop:
		addi $s3, $s3, 1
		j GetElementLoop
	EndGetElementLoop:
	addi $sp, $sp, -4
	sw $t2, 4($sp)		# store before jal
	addi $sp, $sp, -4
	sw $t0, 4($sp)		# store to jal
	jal StrToInt
	
	lw $t1, 4($sp)
	add $sp, $sp, 4
	lw $t2, 4($sp)
	add $sp, $sp, 4
	sw $t1, ($t2)
	addi $t2, $t2, 4

EndParse:
	lw $ra, 4($sp)	# Get return address stored at begin
	addi $sp, $sp , 4	# Free 4 bytes block contains return adress of stack
	jr $ra			# return
StrToInt: 
	lw $t0, 4($sp)		# Get Start position to convert
	addi $sp, $sp, 4		# Free Block read
	lb $t1, ($t0)		# Get char
	li $t2, 0			# $t2 is result
	li $t4, 10
	beq $t1, 45, Negative	# if first char is '-'
	li $t3, 0			# $t3 = 0 set positive
	j StrToIntLoop
	Negative:
		li $t3, 1		# $t3 = 1 set negative
		addi $t0, $t0, 1	# move to next char
	StrToIntLoop:
		lb $t1, ($t0)				# Get char
		beq $t0, $s3, EndStrToIntLoop	# DONE!!!!!!
		mul $t2, $t2, $t4				# r=r*10
		addi $t1, $t1, -48			# char - 48 to get int
		add $t2, $t2 , $t1				# r=r+char
		addi $t0, $t0, 1
		j StrToIntLoop
	EndStrToIntLoop:
		beqz $t3, NotNegative
		neg $t2, $t2
		NotNegative:
		addi $sp, $sp -4		# 4bytes to store result
		sw $t2, 4($sp) 
EndStrToInt:
	jr $ra

OutputArray:
	move $t0, $s0 # t0 = pointer to array
	li $t1, 0 # i =0
	OuputArrayLoop:
	sge $t2, $t1, $s1 # if i >= n, t2 = 1, else t2 = 0
	bnez $t2, EndOutputArrayLoop # if t2 != 0 => t2 = 1 => i >=n => break

	# print data
	li $v0, 1 # v0 = 1 to print integer
	lw $a0, 0($t0) # a0 = integer want to print
	syscall
	addi $t0, $t0, 4 # update
	li $v0, 4 # v0 = 4 to print string
	la $a0, str_space
	syscall

	addi $t1, $t1, 1
	j OuputArrayLoop
EndOutputArrayLoop:
	li $v0, 4 # v0 = 4 to print string
	la $a0, str_endl
	syscall
EndOuputArray:
	jr $ra
IToS:
IToS.prepare:
	lw $t0, 4($sp)			# Num to convert
	addi $sp, $sp, 4
	li $t3, 10				# temp
	li $t5, 0				#count char
	bnez $t0, IToS.NotZero	# If num != 0
IToS.Zero:	
	addi $t5, $t5, 1			# 1 char
	addi $sp, $sp, -1			# 
	li $t0, 48				# '0' is 48
	sb $t0 , 1($sp)			# 
	j IToS.StoreResult
IToS.NotZero:	
	la $t1, itos_Buffer 		# Result
	bgt $t0, 0, IToS.GTZ
IToS.LTZ:
	li $t2, 1
	neg $t0, $t0
	j IToS.Loop				# Checker check sign of element
IToS.GTZ:
	li $t2, 0
	IToS.Loop:
		beqz $t0, EndIToS.Loop
		div $t0, $t3
		mflo $t0
		mfhi $t4
		addi $t4, $t4, 48
		addi $sp, $sp, -1
		sb $t4, 1($sp)
		addi $t5, $t5, 1
		j IToS.Loop
	EndIToS.Loop:
	beqz $t2, IToS.StoreResult
	addi $sp, $sp, -1
	li $t6, 45
	sb $t6, 1($sp)
	addi $t5, $t5, 1 
IToS.StoreResult:
	la $t6, itos_Buffer
	move $a2, $t5
	IToS.StoreResult.Loop:
		beqz $t5, EndIToS.StoreResult.Loop
		lb $t7, 1($sp)
		sb $t7, ($t6)
		addi $sp, $sp, 1
		addi $t5,$t5,-1
		addi $t6, $t6, 1
		j IToS.StoreResult.Loop
	EndIToS.StoreResult.Loop:
	sb $zero, ($t6)
EndIToS:
	jr $ra

WriteArrayToFile:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	# Open file
	li $v0, 13 # $v0 = 13 for open file
	la $a0, path_FileOut # $a0 store path
	li $a1, 1 # Flag read only
	li $a2, 0 # mode is ignored
	syscall
	# Saving decriptor and checking error
	move $s4, $v0

	bgez $s4, NotErrorOut
	# Error part
	li $v0, 4
	la $a0, str_FileNotFound
	syscall
	j CloseFileOut

	NotErrorOut:
	move $t0, $s0
	li $t1,0

	WriteArrayToFileLoop:
		beq $t1, $s1, EndWriteArrayToFileLoop
		
		lw $t2, ($t0)
		
		addi $sp, $sp, -4
		sw $t0, 4($sp)
		addi $sp, $sp, -4
		sw $t1, 4($sp)
		
		addi $sp, $sp, -4
		sw $t2, 4($sp)
		
		jal IToS

		lw $t1, 4($sp)
		addi $sp, $sp, 4
		lw $t0, 4($sp)
		 addi $sp, $sp, 4

		li $v0, 15
		move $a0, $s4
		la $a1, itos_Buffer
		syscall

		li $v0, 15
		la $a1, str_space
		li $a2, 1
		syscall

		addi $t0, $t0, 4
		addi $t1, $t1, 1
		j WriteArrayToFileLoop
	EndWriteArrayToFileLoop:


	CloseFileOut:
		li $v0, 16
		move $a0, $s2
		syscall
EndWriteArrayToFile:
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
Exit:
li $v0, 10
syscall
