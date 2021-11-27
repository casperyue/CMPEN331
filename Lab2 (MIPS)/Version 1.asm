# Version 1, do nothing, then exit
# Switch to the Text segment
	.text
	.globl main
main:
	# rest of the main program will go here
	
	#end program, no explicit return status
	li $v0,10
	syscall
#switch to the Data segments
	.data
#global data will be defined here