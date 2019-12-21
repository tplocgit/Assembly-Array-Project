.data
path_FileIn:		.asciiz "input_sort.txt"
path_FileOut:		.asciiz "output_sort.txt"
str_Loading:		.asciiz "Loading from input_sort.txt...\n"
str_Saving:			.asciiz "Saving into output_sort.txt...\n"
str_Sorting:			.asciiz "Sorting...\n"
str_dataChecking:	.asciiz "Pease Check data: "
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
	
	jal OutputArray
	li $v0, 4
	la $a0, str_Sorting
	syscall


	#move $t0, $s0#a[i] = a[1] ~ addi $t0 , $t0, 4 to get a[++i]
	addi $sp, $sp, -4
	sw $ra, 4($sp) #save $ra 

	li $t1, 0 # left = 0
	addi $sp, $sp, -4
	sw $t1, 4($sp)#push left

	addi $t2, $s1, -1 #right = size - 1
	addi $sp, $sp, -4
	sw $t2, 4($sp)#push right
	jal QuickSort	


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
	# Error notification part
	li $v0, 4
	la $a0, str_FileNotFound
	syscall
	j CloseFile
	
	NotError:# if not have error while open file goto this part
	# Read size
	li $v0, 14 # read file
	move $a0, $s2 # a0 = file decriptor
	la $a1, str_StringOfFileIn # adress of input
	li $a2, 12000 # read max 12000 character
	syscall

	jal Parse # parse data of file intput and store array into heap

	CloseFile:
	li $v0, 16
	move $a0, $s2
	syscall
EndLoadArrayFromFile:
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

Partition:

	lw $t0, 4($sp)
	addi $sp, $sp, 4 #free up stack
	move $t1, $t0 #save $t1 = R

	lw $t2, 4($sp)
	addi $sp, $sp, 4 #free up stack
	move $t3, $t0 #save $t3 = L

	add $t4, $t1, $t3
	div $t4, 2

	mflo $t5 #t5 = mid
	mult $t5, 4
	mflo $t6
	move $t0, $s0
	addi $t0, $t6 #get arr[pivot] 
	
	#XXXXXmove $t7, $s0
	#$t0 = arr[Pivot]
	#$t3 = L
	#$t1 = R
	#$t5 = pivot (mid)
	#$t7 = arr[L]
	#$t9 = arr[R]
	
	LoopPartion:
		bgt $t3, $t1, EndLoopPartition #break condition 
		
		LoopL:
			move $t7, $s0
			mult $t3, 4
			mflo $t6
			addi	$t7, $t6#jump to arr[l]
			
			bgt $t7, $t0, EndLoopL #if(arr[l] > arr[pivot]) break;

			addi $t3, $t3, 1
		EndLoopL:

		LoopR:
			move $t9, $s0
			mult $t1, 4
			mflo $t6
			addi	$t9, $t6#jump to arr[r]
			
			blt $t9, $t0, EndLoopR #if(arr[r] < arr[pivot]) break;

			addi $t1, $t1, -1
		EndLoopR:
			
		Swap:
			bgt $t3, $t1, EndSwapLoop 
			#Swap here
			lw $t8, $t7
			lw $s7, $t9
			sw $s7, ($t7)
			sw $t8, ($t9) 
		EndSwap:
	EndLoopPartiton:
	#push R first
	addi $sp, $sp, -4
	sw $t1, 4($sp)#push left
	#push L
	addi $sp, $sp, -4
	sw $t3, 4($sp)
EndPartition:

QuickSort:
	#get stuff from stack (r - l - $ra)
	lw $t0, 4($sp)
	addi $sp, $sp, 4 #free up stack
	move $t1, $t0 #save R

	lw $t2, 4($sp)
	addi $sp, $sp, 4 #free up stack
	move $t3, $t0 #save L

	bge $t3, $t1, EndQuickSort
	
#===============

	addi $sp, $sp, -4
	sw $t3, 4($sp)#push left
	addi $sp, $sp, -4
	sw $t1, 4($sp)#push right
	j Partition
	lw $t5, 4($sp)	#pop i value
	addi $sp, $sp, 4
	
	lw $t6, 4($sp)	#pop j value
	addi $sp, $sp, 4

	blt $t5, $t3, NoLeftRecursion #pivot > i
		LeftRecursion:
			addi $sp, $sp, -4
			sw $t3, 4($sp)#push left

			addi $sp, $sp, -4
			sw $t5, 4($sp)#push right

			jal QuickSort
		NoLeftRecursion:

	bgt $t6, $t1, NoRightRecursion#pivot > j
		RightRecursion:
			addi $sp, $sp, -4
			sw $t5, 4($sp)#push right

			addi $sp, $sp, -4
			sw $t1, 4($sp)#push right

			jal QuickSort
		NoRightRecursion:
EndQuickSort:
	jr $ra

Parse: # Parse datas of file input and store result
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
		beq $t1, 32, StoreElement # if char is ' '
		beq $t1, 10, EndGetElementLoop # if char is '\n'
		beq $t1, 0, EndGetElementLoop # if null
		j PrepareNextLoop
		StoreElement:
			# Store temp res before jum to sub function
			addi $sp, $sp, -4
			sw $t2, 4($sp)		# store before jal
			
			# Prepare for stoi funtion 
			addi $sp, $sp, -4
			sw $t0, 4($sp)		# Store start position of characters contain number 
			jal StrToInt
			
			# Save result of stoi function
			lw $t1, 4($sp)
			addi $sp, $sp, 4

			# Get datas back to res before next loop
			lw $t2, 4($sp)
			addi $sp, $sp, 4

			# Store result of stoi function
			sw $t1, ($t2)
			addi $t2, $t2, 4

			move $t0, $s3 # update start position of characters contain number
			
			# Move to next character
			addi $t0, $t0,1
		PrepareNextLoop:
		addi $s3, $s3, 1
		j GetElementLoop
	EndGetElementLoop:
	
	GetLastElement:
	# store before jal
	addi $sp, $sp, -4
	sw $t2, 4($sp)	

	# store to jal
	addi $sp, $sp, -4	
	sw $t0, 4($sp)	
	jal StrToInt
	
	# Save result of stoi function
	lw $t1, 4($sp)
	addi $sp, $sp, 4
	# Get datas back to res before next loop
	lw $t2, 4($sp)
	addi $sp, $sp, 4
	# Store result of stoi function
	sw $t1, ($t2)
	EndGetLastElement:
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
IToS.LTZ: # less than 0
	li $t2, 1
	neg $t0, $t0
	j IToS.Loop				# Checker check sign of element
IToS.GTZ: # greater than 0
	li $t2, 0
	IToS.Loop:
		beqz $t0, EndIToS.Loop
		div $t0, $t3 # num / 10
		mflo $t0	# get result of num / 10
		mfhi $t4	# get num modulus 10
		addi $t4, $t4, 48 # a number from 0 to 9 + 48 is char value of this number
		
		# Store to stack to get reverse result at end
		addi $sp, $sp, -1 
		sb $t4, 1($sp)
		
		# Prepare to next loop
		addi $t5, $t5, 1
		j IToS.Loop
	EndIToS.Loop:

	# check sign
	beqz $t2, IToS.StoreResult # $t2 contain sign
	# Add a '-' character if num is negative
	addi $sp, $sp, -1
	li $t6, 45 # '-' is 45
	sb $t6, 1($sp) # store
	addi $t5, $t5, 1 # add number of characters by 1
IToS.StoreResult:
	la $t6, itos_Buffer # string store result
	move $a2, $t5 # a2 = number of character got
	IToS.StoreResult.Loop:
		beqz $t5, EndIToS.StoreResult.Loop # if have store all charracters break

		# Load character got from stack
		lb $t7, 1($sp)
		addi $sp, $sp, 1
		# Store character to string
		sb $t7, ($t6)

		# Prepare next loop
		addi $t5,$t5,-1
		addi $t6, $t6, 1
		j IToS.StoreResult.Loop
	EndIToS.StoreResult.Loop:
	sb $zero, ($t6) # Store th '\0' to end of string
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
		
		# Store temp res before jum to sub function
		addi $sp, $sp, -4
		sw $t0, 4($sp)
		addi $sp, $sp, -4
		sw $t1, 4($sp)
		
		# Store the num to stack to convert
		addi $sp, $sp, -4
		sw $t2, 4($sp)
		
		jal IToS

		# Get temp res value back
		lw $t1, 4($sp)
		addi $sp, $sp, 4
		lw $t0, 4($sp)
		addi $sp, $sp, 4

		# Write element converted
		li $v0, 15
		move $a0, $s4
		la $a1, itos_Buffer
		syscall

		# Write space
		li $v0, 15
		la $a1, str_space
		li $a2, 1
		syscall

		# Prepare next loop
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
