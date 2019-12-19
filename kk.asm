.data
# Menu string
p_InputSizeStr:		.asciiz "Please input size of array:\t"
p_InputIntStr:		.asciiz "Please input intergers\n"
p_StartInputElmStr:	.asciiz "a["
p_EndInputElmStr:	.asciiz "] =\t"
p_OuputStr: 		.asciiz "Ouput:\n"
p_endl:			.asciiz "\n"
p_notFound:		.asciiz "Error 404: X not found\n"
p_Space:			.asciiz " "
p_SortedOutput:	.asciiz "Sorted array:\n"
p_Loop: .asciiz "Looping"
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


	jal OutputArray

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

QuickSort:
	lw $t0, 4($sp)
	addi $sp, $sp, 4 #pop L
	move $t1, $t0 #save L

	lw $t0, 4($sp)
	addi $sp, $sp, 4 #pop R
	move $t2, $t0 #save R

	bge $t1, $t2, EndQuickSort #if (L >= R) return
	#partition preparation
	addi $sp, $sp, -4
	sw $ra, 4($sp)#ra2

	addi $sp, $sp, -4
	sw $t2, 4($sp)#push right

	addi $sp, $sp, -4
	sw $t1, 4($sp)#push left

	jal Partition


	lw $t0, 4($sp)
	addi $sp, $sp, 4 #pop pivot
	move $t3, $t0 #save pivot
	move $t4, $t3

	addi $t3, $t3, -1
	addi $t4, $t4, 1


	ble $t3, $t1, NoLeftRecursion #pivot < L
		LeftRecursion:
			addi $sp, $sp, -4
			sw $ra, 4($sp)

			addi $sp, $sp, -4
			sw $t3, 4($sp)#push right

			addi $sp, $sp, -4
			sw $t1, 4($sp)#push left

			jal QuickSort
		NoLeftRecursion:

	bge $t4, $t2, NoRightRecursion#pivot > R
		RightRecursion:
			addi $sp, $sp, -4
			sw $ra, 4($sp)

			addi $sp, $sp, -4
			sw $t2, 4($sp)#push right

			addi $sp, $sp, -4
			sw $t4, 4($sp)#push left

			jal QuickSort
		NoRightRecursion:
	lw $t0, 4($sp)
	addi $sp, $sp, 4
EndQuickSort:
	jr $t0

Partition:
	lw $t0, 4($sp)
	addi $sp, $sp, 4 #pop L
	move $t1, $t0 #save L

	lw $t0, 4($sp)
	addi $sp, $sp, 4 #pop R
	move $t2, $t0 #save R
	#----
	li $t4, 4
	move $t3, $t1 #$t3 = L
	mult $t3, $t4
	mflo $t3 # $3 -> 4(L)

#$t1 = L
#$t2 = R
#$t3 = i
#$t4 = j
#$t5 = pivotValue
#$t6 = arr[i]
#$t7 = arr[j]
#$t9 holder (4)
#$t8 holder
	move $t0, $s1#Assign pointer
	add $t0, $t0, $t3 #get arr[4(L)]
	move $t5, $t0 #$t5 = pivotValue

	move $t3, $t1
	addi $t3, $t3, 1 #i = Left + 1

	move $t4, $t2 #j = right

	PartitionLoop:
		LoopL:
			bgt $t3, $t4, EndLoopL # if(i > j) break

			#--get arr[L]
			li $t9, 4
			mult $t3, $t9
			mflo $t8 # $t8 hold -> 4(L)

			move $t0, $s1#Assign pointer
			add $t0, $t0, $t8 #get arr[4(L)]
			move $t6, $t0

			bge $t6, $t5, EndLoopL  #if (arr[i] >= pivotValue) break
			addi $t3, $t3, 1 #++L

			j LoopL
		EndLoopL:


		LoopR:

			bgt $t3, $t4, EndLoopR # if(i > j) break

			#--get arr[L]
			li $t9, 4
			mult $t4, $t9
			mflo $t8 # $t8 hold -> 4(L)

			move $t0, $s1#Assign pointer
			add $t0, $t0, $t8 #get arr[4(L)]
			move $t7, $t0

			blt $t7, $t5, EndLoopR  #if (arr[i] < pivotValue) break
			addi $t4, $t4, -1 #--R

			j LoopR
		EndLoopR:
		bge $t3, $t4, EndPartitionLoop

		#Swap(arr[i], arr[j])
		lw $t8, ($t7)
		lw $t9, ($t6)
		sw $t9, ($t7)
		sw $t8, ($t6)
		#===================
		j PartitionLoop

	EndPartitionLoop:
 #if(arr[r] < pivotValue)
 #      swap(arr[left], arr[r]);

	#get arr[r]
		li $t9, 4
		mult $t4, $t9
		mflo $t8 # $t8 hold -> 4(L)

		move $t0, $s1#Assign pointer
		add $t0, $t0, $t8 #get arr[4(L)]
		move $t7, $t0

		bge $t7, $t5, EndPartition
	#get arr[left]	
		li $t9, 4
		mult $t1, $t9
		mflo $t8 # $t8 hold -> 4(L)

		move $t0, $s1#Assign pointer
		add $t0, $t0, $t8 #get arr[4(L)]
		move $t6, $t0
	#Swap
		lw $t8, ($t7)
		lw $t9, ($t6)
		sw $t9, ($t7)
		sw $t8, ($t6)
EndPartition:
#pop previous $ra
	lw $t0, 4($sp)
	addi $sp, $sp, 4 #pop $ra

	addi $sp, $sp, -4
	sw $t4, 4($sp) #return j
	jr $t0
Exit:
	addi $v0,$0,10
	syscall
