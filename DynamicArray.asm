.data
strHello: .asciiz "Hello World!!!\n"
.text
main:
addi $v0,$0,4
la $a0,strHello
syscall


Exit:
addi $v0,$0,10
syscall
