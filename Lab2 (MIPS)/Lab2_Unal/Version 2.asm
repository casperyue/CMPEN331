# Version 2, do nothing, then Exit

# switch to the Text segment
	.text
	
	.globl main
main:
	#rest of the main program will go here
	
	#call function Exit0
	jal Exit0 #end program, default return status
#------------------------------------------------------------------
# Wrapper functions around some of the system calls
# See P&H COD, Fig. A.9.1, for the complete list.

# switch to the text segment
	.text
	
	.globl Print_integer
Print_integer: #print integer in register $a0
	li $v0,1
	syscall
	jr $ra
	
	.globl Print_String # essentially a variable to tell what can reference the Print String
Print_String:
	li $v0,4
	syscall
	jr $ra
	
	.globl Exit
Exit: #end program here, no explicit return status
	li $v0, 10
	syscall
	jr $ra #instruction never executed
	
	.globl Exit0

Exit0: #ends the program, default return status
	li $a0, 0 #return status 0 
	li $v0, 17
	syscall
	jr $ra #instruction never executes
	
	.globl Exit2
Exit2: #end the program with return status from register $a0
	li $v0, 17
	syscall
	jr $ra #this instruction is never executed.
	
	
