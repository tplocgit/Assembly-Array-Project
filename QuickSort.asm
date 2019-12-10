.data
path_FileIn:		.asciiz "input_sort.txt"
path_FileOut:		.asciiz "output_sort.txt"
str_Loading:		.asciiz "Loading from input_sort.txt...\n"
str_Saving:			.asciiz "Saving into output_sort.txt...\n"
str_Sorting:		.asciiz "Sorting...\n"
str_dataChecking:	.asciiz "Please Check data: "
str_space:			.asciiz " "
str_endl:			.asciiz "\n"
str_FileNotFound: 	.asciiz "Error XXX: File not found\n"
str_StringOfFileIn:	.asciiz "" 
.text
.globl main


#$s0: array pointer
#s1: number of elements    

main:
	li $v0, 4
	la $a0, str_Loading
	syscall
	jal LoadArrayFromFile

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
	jal SaveArrayIntoFile
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
	move $s3, $v0
	bgez $s3, NotError
	# Error part
	li $v0, 4
	la $a0, str_FileNotFound
	syscall
	j CloseFile
	
	NotError:
	# Read size
	li $v0, 14 # read file
	move $a0, $s3 # a0 = file decriptor
	la $a1, str_StringOfFileIn # adress of input
	li $a2, 100
	syscall

	jal Parse

	CloseFile:
	li $v0, 16
	move $a0, $s3
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

	addi $t4, $t1, $t3
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
SaveArrayIntoFile:
EndSaveArrayIntoFile:
	jr $ra

Parse:
	addi $sp, $sp, -4 			# Request 4 bytes memory in stack to store return address
	sw $ra, 4($sp) 			# Store return address to stack
	la $t0, str_StringOfFileIn 	# Get a pointer to begin of string got from file
 	addi $sp, $sp, -4 			# Request 4 bytes memory in stack to store $t0
	sw $t0, 4($sp)			# Store address to block to getline
	jal GetLine 				# Get a line from string read from file
						# The last 4bs-block in stack must contain address of string 
						# Returned value is stack of line + number of chars read stored in stack
	lb $s2, 1($sp)			# Get number of chars read to calc next line
	# StringToInt will remove number of characters read and all charracters read
	# And push returned Integer to stack
	# So we don't need to free them after call
	jal StrToInt				# Return integer store in last 4 bytes block in stack
	lw $s1, 4($sp)			# Load size into $s1
	addi $sp, $sp , 4			# Free 4 bytes block contains Size of stack
	la $t0, str_StringOfFileIn	# Get the address of string of file
	add $s2, $t0, $s2			# Move address read to '\n'
	addi $s2, $s2, 1			# Increase it by one to ignore '\n'
	move $t0, $s2			# Copy address	
	# Allocate array
	li $t1, 4				# $t1 = 4-bytes
	mul $a0, $s1, $t1			# $a0 = n * 4 
	li $v0, 9				# $v0 = 9 for allocate
	syscall
	move $s0, $v0			# Save address of array to $s0
	move $t2, $s0			# Make a copy for store
	li $v0, 4
	la $a0, ($t0)
	syscall
	ParseLoop:
		lb $t1, ($t0)
		beq $t1, 10, EndParseLoop	# if end of line break
		beq $t1,  32, StoreIntoArray	# if ' ' goto prepare
		addi $sp, $sp, -1			# Ask a 1 byte block to store char
		sb $t1, 1($sp)			# Store char to stack
		j ParseContinue
		StoreIntoArray:
		sub $t3, $t0, $s2			# Calc number of characters
		addi $sp, $sp, -1			# Ask 1 block
		sb $t3, 1($sp)			# Store num to stack
		move $s2, $t0			# Update
		addi $s2, $s2, 1			# Ignore ' '
		jal StrToInt
		lw $t5, 4($sp)			# Save return value
		addi $sp, $sp, 4			# Free block
		sw $t5, ($t2)			# Store into array
		addi $t2, $t2, 4			# Next element
		ParseContinue:
		addi $t0, $t0, 1			# $t0++
		j ParseLoop
	EndParseLoop:
EndParse:
	lw $ra, 4($sp)	# Get return address stored at begin
	addi $sp, $sp , 4	# Free 4 bytes block contains return adress of stack
	jr $ra			# return

StrToInt: # Get the last block as number of character in string
	lb $t0, 1($sp)				# Get number of characters convert
	addi $sp, $sp , 1				# Free the block loaded
	li $t1, 0					# $t1 = 0 to start loop
	li $t3, 1					# Exp to calc number, 10^num
	li $t4, 0					# Result

	StrToIntLoop:
	bge $t1, $t0, EndStrToIntLoop	# If read enough number of character break
	lb $t5, 1($sp)				# Get character from stack
	addi $sp, $sp, 1				# Free block contain characters read
	bne $t5, 45, NotSignChar		# If $t5 is not '-'
		neg $t4, $t4			# If $t5 is sign char $t4 = - $t4
	j EndStrToInt				# Sign char is last char we must convert
	NotSignChar:
	addi $t5, $t5, -48			# Char = Char - 48 to get its int value
	mul $t5, $t5, $t3				# $t5 = $t5 * 10^n
	add $t4, $t4, $t5				# result += $t5
	# Prepare for next loop
	addi $t1, $t1, 1				# $t1++
	li $t6, 10
	mul $t3, $t3, $t6				# $t3 *= 10
	j StrToIntLoop
	EndStrToIntLoop:
	addi $sp, $sp , -4				# Ask 4bs-block to store result
	sw $t4, 4($sp)				# Store result to block asked
EndStrToInt:
	jr $ra
GetLine: #Return value will store in stack, the last block in stack contain number of characters read
		lw $t0, 4($sp) 	# Get address of fist character in line
		addi $sp, $sp, 4 	# Free 4 bytes block of address in stack
		move $t1, $t0	# Get coppy of address to calc later
	GetLineLoop: 
		lb $t2, ($t0) 				# Get value of current pointer
		beq $t2, 10, EndGetLineLoop 	# if character read == '\n' break loop (;\n' = 10 in ascii)
		# 1 character in ascii is decriped by 8 bits (1 byte)
		addi $sp, $sp, -1 	# Ask 1 byte from stack
		sb $t2, 1($sp)	# Store character got from pointer into block got from stack
		# t0++
		addi $t0, $t0, 1	# Get next character
		j GetLineLoop 	# Continue loop
	EndGetLineLoop:	
	sub $t0 $t0, $t1	# Last address - First Address = number of characters read
	addi $sp, $sp, -1	# Ask a 4 bytes block of stack to store num
	sb $t0, 1($sp)	# Store num into stack
EndGetLine:
	jr $ra
Exit:
li $v0, 10
syscall
