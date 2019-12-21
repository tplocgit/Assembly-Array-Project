.data
# Menu string
p_InputSizeStr:		.asciiz "Please input size of array:\t"
p_InputIntStr:		.asciiz "Please input intergers\n"
p_StartInputElmStr:	.asciiz "a["
p_EndInputElmStr:	.asciiz "] =\t"
p_OuputStr: 		.asciiz "Ouput:\t"
p_endl:			.asciiz "\n"
p_notFound:		.asciiz "Error 404: X not found\n"
p_Space:			.asciiz " "
p_SortedOutput:	.asciiz "Sorted array:\n"

.text

.globl main

# $s0 = size
# $s1 = array pointer
# Input size of array
main:
	InputSize:
	li $v0, 4 # $v0 = 4 to print string
	la $a0,  p_InputIntStr # $a0 = string to print
	syscall

# Print string to remind input integer
	li $v0, 4 # $v0 = 4 to print srting
	la $a0,  p_InputSizeStr # $a0 = string to print
	syscall

# Input Size
	li $v0,  5 # $vo=5 to input an integer number, $v0 contain number read
	syscall
# Check if n > 0
	CheckSizeLoop:
	sle $t0, $v0, $zero # if $v0(number inputed) > $0  => $t1 = 1 else $t1 = 0
	bnez $t0, InputSize # if $t1 = 0  => $v0 !> 0 =>$v0 <= 0 => goto InputSize <=> while(n<=0) cin >> n

	EndCheckSizeLoop:
	move $s0, $v0 # $s0 = $v0 to save an integer inputed, $t0 contain size of array
	EndInputSize:

	# Task
	# Input array
	li $v0, 4 # v0= 4 to print string
	la $a0, p_InputIntStr # a0 = adress to print
	syscall
	jal InputArray

	#=Print menu=
	bne $v0, 1, case2
	jal OutputArray
		

#----------------------------------------------------------
	#move $t0, $s0#a[i] = a[1] ~ addi $t0 , $t0, 4 to get a[++i]
	addi $sp, $sp, -4
	sw $ra, 4($sp) #save $ra 


	addi $t1, $s0, -1 #right = size - 1
	addi $sp, $sp, -4
	sw $t1, 4($sp)#push right

	li $t1, 0 # left = 0
	addi $sp, $sp, -4
	sw $t1, 4($sp)#push left

	
	jal QuickSort			
	li $v0, 4
	la $a0, p_SortedOutput
	syscall

EndMain:
j Exit
# Function Part
# $tx is template res so just use it =))
# $s0 contain size
# $s1 contian Adress of array
InputArray:
	# Allocate Heap memory, int* a = new int[n]
	li $v0, 9 # v0 = 9 to allocate memory
	li $t0, 4 # t0 = 4 byte
	mult $s0, $t0 # calculate size of memory n * 4
	mflo $a0 # a0 = size calculated
	syscall # allocate, (a0 = size * 4) bytes, v0 contain adress
	move $s1, $v0 # s1 = v0, Contain array pointer
	la $t0, 0($s1) # save pointer
	# Input data
	li $t1, 0 # Init $t01= i = 0
	InputArrayLoop: # Start Loop
		# Codision
		sge $t2,  $t1,  $s0 # if ($t1 >= $s0) => (i >= n) => $t2 = 1 else $t2 = 0
		bnez $t2, EndInputArrayLoop # (t2 != 0) => ($t1 = 1) => break

		#Print string: "a[i] = "
		li $v0,  4 # Print string
		la $a0, p_StartInputElmStr # a0 = value to print
		syscall
		li $v0,  1 # print integer
		move $a0, $t1  # a0 = value to print
		syscall
		li $v0,  4 # Print string
		la $a0, p_EndInputElmStr # a0 = value to print
		syscall

		# Read integer as element
		li $v0, 5 # Read num, v0 contain it
		syscall
		sw $v0, 0($t0) # Save inputed to arr
		addi $t0, $t0, 4 # get next position

		# i++
		addi $t1, $t1, 1
		j InputArrayLoop
	EndInputArrayLoop:
EndInputArray:
	jr $ra # return

OutputArray:
	move $t0, $s1 # t0 = pointer to array
	li $t1, 0 # i =0
	OuputArrayLoop:
	sge $t2, $t1, $s0 # if i >= n, t2 = 1, else t2 = 0
	bnez $t2, EndOutputArrayLoop # if t2 != 0 => t2 = 1 => i >=n => break

	# print data
	li $v0,  4 # Print string
	la $a0, p_StartInputElmStr # a0 = value to print
	syscall
	li $v0,  1 # print integer
	move $a0, $t1  # a0 = value to print
	syscall
	li $v0,  4 # Print string
	la $a0, p_EndInputElmStr # a0 = value to print
	syscall
	li $v0, 1 # v0 = 1 to print integer
	lw $a0, 0($t0) # a0 = integer want to print
	syscall
	addi $t0, $t0, 4 # update
	li $v0, 4 # v0 = 4 to print string
	la $a0, p_endl
	syscall

	addi $t1, $t1, 1
	j OuputArrayLoop
EndOutputArrayLoop:
EndOuputArray:
	jr $ra

Partition:
	#$t5 = pivot (mid)
	#$t0 = arr[Pivot]
	#$t1 = L
	#$t2 = R
	#$t7 = arr[L]
	#$t9 = arr[R]
	#$t4
	#$t8
	lw $t0, 4($sp)
	addi $sp, $sp, 4 #pop L
	move $t1, $t0 #save $t1 = L

	lw $t3, 4($sp)
	addi $sp, $sp, 4 #pop R
	move $t2, $t3 #save $t2 = R
	
	#------------------------------
	add $t4, $t1, $t2
	div $t5, $t4, 2 #pivot = (left + right) / 2
	
	li $t6, 4
	mult $t5, $t6
	mflo $t6
	add $t0, $t6 #$t0 =  arr[pivot] 
	#move $t0, $s1

	LoopPartion:
		bgt $t1, $t2, EndLoopPartition # while (L <= R)
		move $t7, $s1#point to a[0]
		LoopL:	
			bgt $t7, $t0, EndLoopL #if(arr[L] > arr[pivot]) break;

			addi $t1, $t1, 1		#else ++L
			addi $t7, $t7, 4 # arr[i] -> arr[++i]
			j LoopL
		EndLoopL:

		move $t9, $s1#point to a[0]
		li $t6, 4
		mult $t2, $t6
		mflo $t6
		LoopR:
			blt $t9, $t0, EndLoopR #if(arr[R] < arr[pivot]) break;

			addi $t2, $t2, -1
			addi $t6, $t6, -4
			j LoopR
		EndLoopR:
			
		Swap:
			#$t5 = pivot (mid)
			#$t0 = arr[Pivot]
			#$t1 = L
			#$t2 = R
			#$t7 = arr[L]
			#$t9 = arr[R]
	
			bgt $t1, $t2, EndSwap #if(L > R) break
			#Swap here
			lw $t8, $t7
			lw $t4, $t9
			sw $t4, ($t7)
			sw $t8, ($t9) 
		EndSwap:
	EndLoopPartiton:
	#push R first
	addi $sp, $sp, -4
	sw $t2, 4($sp)
	#push L
	addi $sp, $sp, -4
	sw $t1, 4($sp)
EndPartition:

QuickSort:
	#get stuff from stack (l - r - $ra)
	lw $t0, 4($sp)
	addi $sp, $sp, 4 #pop L
	move $t1, $t0 #save L

	lw $t0, 4($sp)
	addi $sp, $sp, 4 #pop R
	move $t2, $t0 #save R

	bge $t1, $t2, EndQuickSort #if (L >= R) return
	
#===============

	addi $sp, $sp, -4
	sw $t2, 4($sp)#push right

	addi $sp, $sp, -4
	sw $t1, 4($sp)#push left

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

Exit:
	addi $v0,$0,10
	syscall
