.data
strHello: .asciiz "Hello World!!!\n"
.text
main:
addi $v0, $zero, 5 #$vo=5 to input an integer number, $v0 contain number read
syscall
add $t0,$zero,$v0 #$t0 = $v0 to save an integer inputed, $t0 contain size of array

InputArray:

OutputArray:

SumArray:

CheckPrime:

FindMax:

SearchX:

PrintMenu:



Exit:
addi $v0,$0,10
syscall
