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
.text
.globl main


main:
	li $v0, 4
	la $a0, str_Loading
	syscall
	jal LoadArrayFromFile

	li $v0, 4
	la $a0, str_Sorting
	syscall
	jal QuickSort	

	li $v0, 4
	la $a0, str_Saving
	syscall
	jal SaveArrayIntoFile
Endmain:
j Exit

LoadArrayFromFile:
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
	li $v0, 14 #
	move $a0, $s3 
	la $a1, ($s0)	
	li $a2, 1
	syscall
	
	move $t0, $s0
	li $v0, 11
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, str_endl
	syscall

	CloseFile:
	li $v0, 16
	move $a0, $s3
	syscall
EndLoadArrayFromFile:
	jr $ra

QuickSort:
EndQuickSort:
	jr $ra
SaveArrayIntoFile:
EndSaveArrayIntoFile:
	jr $ra




Exit:
li $v0, 10
syscall