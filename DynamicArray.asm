.data
# Menu string
p_InputSizeStr:		.asciiz "Please input size:\t"
p_InputIntStr:		.asciiz "Please input intergers:\n"
p_StartInputElmStr:	.asciiz "a["
p_EndInputElmStr:	.asciiz "] =\t"
p_OuputStr: 		.asciiz "Ouput:\t"
p_SumStr:			.asciiz "Sum:\t"
p_PrimeStr:		.asciiz "Prime:\t"
p_MaxStr: 			.asciiz "Max:\t"
p_endl:			.asciiz "\n"
.text


main:
# $s0 = size
# $s1 = array pointer
# Input size of array
InputSize:
li $v0, 4 # $v0 = 4 to print srting
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
# Output array
li $v0, 4 # v0= 4 to print string
la $a0, p_OuputStr # a0 = adress to print
syscall
li $v0, 4 # v0= 4 to print string
la $a0, p_endl # a0 = adress to print
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

SumArray:
EndSumArray:
jr $ra

CheckPrime:
EndCheckPrime:
jr $ra

FindMax:
EndFindMax:
jr $ra

SearchX:
EndSearchX:
jr $ra

PrintMenu:
EndPrintMenu:
jr $ra

Exit:
addi $v0,$0,10
syscall
