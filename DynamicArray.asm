.data
# Menu string
p_InputSizeStr:		.asciiz "Please input size of array:\t"
p_InputIntStr:		.asciiz "Please input intergers\n"
p_StartInputElmStr:	.asciiz "a["
p_EndInputElmStr:	.asciiz "] =\t"
p_OuputStr: 		.asciiz "Ouput:\t"
p_SumStr:			.asciiz "Sum of all elements =\t"
p_PrimeStr:         		.asciiz "Prime:\t"
p_MaxStr: 			.asciiz "Max:\t"
p_endl:			.asciiz "\n"
p_menu:			.asciiz "1. Print all elements\n2. Sum all elements\n3. List all prime elements\n4. Find largest elements\n5. Search a value in array\n6. Exit"
p_requestInput:		.asciiz "\n\nEnter a number (1 -> 6) to proceed:\t"
p_requestX:		.asciiz "Please enter X = \t"
p_notFound:		.asciiz "Error 404: X not found\n"
p_FoundAt:		.asciiz "Found X at position p =\t"
p_ResultPrime:		.asciiz "Prime searching result:\t"
p_NoPrime: 		.asciiz "No prime number was found in array\n"
p_Space:			.asciiz " "
p_FindMax:		.asciiz "\nMax value in array is:\t"
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
	Menu:
	li $v0, 4 # $v0 = 4 to print string
	la $a0,  p_menu # $a0 = string to print
	syscall

	RequestInput:
	li $v0, 4 # $v0 = 4 to print string
	la $a0,  p_requestInput # $a0 = string to print
	syscall

	li $v0, 5 #get choiceNum
	syscall
	case1: bne $v0, 1, case2
		jal OutputArray
		j RequestInput
	case2: bne $v0, 2, case3	
		jal SumArray
		j RequestInput	
	case3: bne $v0, 3, case4	
		jal ListPrime
		j RequestInput
	case4: bne $v0, 4, case5
		jal FindMax
		j RequestInput
	case5: bne $v0, 5, case6
		li $v0 ,4
		la $a0, p_requestX
		syscall
		li $v0, 5
		syscall		
		jal SearchX
		j RequestInput		
	case6: bne $v0, 6, RequestInput	
		j EndMenu
	EndMenu:
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

SumArray:
	# Calculate Sum
	li $t0, 0 # t0 = 0 for loop
	la $t1, 0($s1) # pointer to array
	li $t2, 0 # store sum in here
	SumLoop:
	#get element and calculate
	bge $t0, $s0, EndSumLoop # base case: if t0 >= s0 (size) break
	lw $t3, 0($t1) # get value of element
	add $t2, $t2, $t3 # t2+=t3
	# Prepare for next loop and go to next loop
	add $t1, $t1, 4 # move to next element
	addi $t0, $t0, 1 # t0++
	j SumLoop
	EndSumLoop:
	# Print result
	li $v0, 4 # $v0 = 4 to print string
	la $a0, p_SumStr
	syscall
	li $v0, 1 # $v0 = 1 to print integer
	move $a0, $t2 # a0 = value to print
	syscall
EndSumArray:
	jr $ra

CheckPrime:
	lw $t0, 4($sp)
	lw $t1, ($t0) #get value from $t0 to dividant
	bne $t1, 2, Not2
	j PrimeTrue
	Not2:
	ble $t1, 1, PrimeFalse

	#set value (i, divisor, . . . )
	li $t2, 2 # divisor = 2 
	div $t1, $t2
	mflo $t3 # val / 2
		
	LoopCheckPrime:
		bgt $t2, $t3, EndLoopCheckPrime #break condition
		div $t1, $t2
		mfhi $t4 
		
		beqz $t4, PrimeFalse
		addi $t2, $t2, 1 # ++i
		j LoopCheckPrime
	EndLoopCheckPrime:
	
PrimeTrue:
	li $t0, 1
	j EndCheckPrime
PrimeFalse:
	li $t0, 0
EndCheckPrime:
	addi $sp, $sp, -4
	sw $t0, 4($sp)
	jr $ra

ListPrime:	
		li $v0, 4#Print " ~ "
		la $a0, p_ResultPrime
		syscall

		addi $sp, $sp, -4
		sw $ra, 4($sp)
		li $t6, 0 # i = 0
		move $t0, $s1#a[i] = a[1]
		li $t9, 0
	ListPrimeLoop: 
		bge $t6, $s0, EndListPrimeLoop #break condition

		addi $sp, $sp, -4
		sw $t6, 4($sp)#push i

		addi $sp, $sp, -4
		sw $t0, 4($sp)#push a[i]

		jal CheckPrime
		 
		lw $t5, 4($sp)  # result of last function
		addi $sp, $sp, 4

		lw $t0, 4($sp)#pop a[i]
		addi $sp, $sp, 4
		beqz $t5, NotPrime # t5 == false => not prime
		# Print prime
		IsPrime:
		addi $t9, $t9, 1
		lw $a0,  ($t0)
		li $v0, 1
		syscall

		li $v0, 4
		la $a0, p_Space
		syscall

		NotPrime:	#continue the loop

		lw $t6, 4($sp)
		addi $sp, $sp, 4

		addi $t6, $t6, 1
		addi $t0, $t0, 4
		#addi $sp, $sp, 4 #pop
		j ListPrimeLoop
	EndListPrimeLoop:
	bnez $t9, HavePrime

	NoPrime:
	li $v0, 4
	la $a0, p_NoPrime
	syscall

	HavePrime:
	lw $ra, 4($sp)
	addi $sp, $sp, 4

EndListPrime:
	jr $ra
FindMax:
	li $t1, 1 # i =0
	move $t0, $s1#a[i] = a[0]
	lw $t2, ($t0)#ans
	LoopFindMax:
		bgt $t1, $s0, EndLoopFindMax
		lw $t3, ($t0)
		
		ble $t3, $t2, NoSwapMax
		SwapMax:
			move $t2, $t3 #	update max value
		NoSwapMax:
			addi $t0, $t0, 4
			addi $t1, $t1, 1
	j LoopFindMax
	EndLoopFindMax:

	li $v0, 4
	la $a0, p_FindMax
	syscall

	li $v0, 1
	move $a0, $t2
	syscall
EndFindMax:
	jr $ra

SearchX:
	la $t0, 0($s1) # pointer to array
	move $t2, $v0 # t2 = X to find ~ reservation
	li $t1, 4 # 4 bytes
	mult  $t1, $s0 # Calculate to find last element
	mflo $t1 # Get size of memory
	subi $t1, $t1, 4 # t1 = t1 - 4 => point to last element
	add $t1, $t1, $t0 # Update t1 become real pointer
	lw $t3, 0($t1) # save last element
	sw $t2, 0($t1) # set last element equal to X
	li $t4, 0 # t3 = 0 store index
	SearchXLoop:
		lw $t5, 0($t0)
		beq $t5, $t2, EndSearchXLoop # if a[i] == x break, 
	# Cause last index auto == x so dont need to check size
		addi $t0, $t0, 4
		addi $t4, $t4, 1 
		j SearchXLoop
	EndSearchXLoop:
	subi $t5, $s0, 1 # t5 = n - 1
	seq $t3, $t3, $t2 # if t3 = X , t3 = 1 else 0
	slt $t5, $t4, $t5 # if index found < n - 1 t5 = 1 else = 0
	add $t5, $t5, $t3 # add t5 and t3 to check if t5 + t3 > 0 => found X in array else not
	bnez $t5, PrintPosX # if t5 != 0 => found X => goto print position  
	li $v0, 4
	la $a0, p_notFound
	syscall
	j EndSearchX
	PrintPosX:
		li $v0, 4
		la $a0, p_FoundAt
		syscall
		li $v0, 1
		move $a0, $t4
		syscall
		li $v0, 4
		la $a0, p_endl
		syscall
EndSearchX:
	jr $ra

Exit:
	addi $v0,$0,10
	syscall