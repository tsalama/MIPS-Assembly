#*******************************************************************************
# FILE: hw4-1.s
#
# AUTHOR INFO
# Tarek Salama (tsalama@asu.edu)
# Moses Habib (mhabib4@asu.edu)
#*******************************************************************************

#-------------------------------------------------------------------------------------------------------------
# FUNCTION: void main()

# DESCRIPTION
# Prompts the user to enter three integer coefficients of a 2nd-degree polynomial and the value (x) at which
# to evaluate the polynomial. Evaluates the polynomial at x and displays the result.

# PARAMETERS
# None

# PSEUDOCODE
# function main() returns nothing
# 	int c0, c1, c2, p_of_x, x
# 	c2 = getint("Enter c2? ")
# 	c1 = getint("Enter c1? ")
# 	c0 = getint("Enter c0? ")
# 	x = getint("Enter x? ")
# 	p_of_x = evalpoly(c0, c1, c2, x)
# 	print("p(x) = ", p_of_x)
# 	SysExit()
# end function

# RETURNS
# Nothing. Exits by calling SysExit().

# STACK FRAME
# Note that MARS initializes $sp to 0x7fff_effc before main() begins executing. We allocate five local
# variables all ints (words). This requires 5 words x 4 bytes/word = 20 bytes of stack space.
# Name of var Offset rel to $sp Memory addresses
# ---------------- ----------------- -------------------------
# local var x 16($sp) 0x7fff_eff8 - 0x7fff_effb
# local var p_of_x 12($sp) 0x7fff_eff4 - 0x7fff_eff7
# local var c2 8($sp) 0x7fff_eff0 - 0x7fff_eff3
# local var c1 4($sp) 0x7fff_efec - 0x7fff_efef
# local var c0 0($sp) 0x7fff_efe8 - 0x7fff_efeb
#-------------------------------------------------------------------------------------------------------------

#===============================================================================
# System Call Equivalents
#===============================================================================
.eqv SYS_EXIT       10
.eqv SYS_PRINT_INT   1
.eqv SYS_PRINT_STR   4
.eqv SYS_READ_INT    5

#===============================================================================
# DATA SECTION
#===============================================================================
.data

# Define string literals.
s_prompt_c0: .asciiz  "Enter c0? "
s_prompt_c1: .asciiz  "Enter c1? "
s_prompt_c2: .asciiz  "Enter c2? "
s_prompt_x:  .asciiz  "Enter x? "
s_result:    .asciiz  "p(x) = "

#===============================================================================
# TEXT SECTION
#===============================================================================
.text
main: 

addi	$sp, $sp, -24		# allocate 6 words in stack frame
sw	$ra, 20($sp)		# Save $ra	

# c2 = getint("Enter c2? ")
la	$a0, s_prompt_c2	# $a0 = addr of s_prompt_c2
jal	getint			# Call getint()
sw	$v0, 8($sp)		# c2 = getint("Enter c2? ")

# c1 = getint("Enter c1? ")
la	$a0, s_prompt_c1	# $a0 = addr of s_prompt_c1
jal	getint			# Call getint()
sw	$v0, 4($sp)		# c1 = getint("Enter c1? ")

# c0 = getint("Enter c0? ")
la	$a0, s_prompt_c0	# $a0 = addr of s_prompt_c0
jal	getint			# Call getint()
sw	$v0, 0($sp)		# c0 = getint("Enter c0? ")

# x = getint("Enter x? ")
la	$a0, s_prompt_x		# $a0 = addr of s_prompt_x
jal	getint			# Call getint()
sw	$v0, 16($sp)		# x = getint("Enter x? ")

# p_of_x = evalpoly(c0, c1, c2, x)
lw	$a0, 0($sp)		# $a0 = c0
lw	$a1, 4($sp)		# $a1 = c1
lw	$a2, 8($sp) 		# $a2 = c2
lw	$a3, 16($sp)	 	# $a3  = x
jal	evalpoly		# call evalpoly(c0, c1, c2, x)
sw	$v0, 12($sp) 		# p_of_x = evalpoly(c0, c1, c2, x)

# print("p(x) = ", p_of_x)
la	$a0, s_result		# $a0 = addr of s_result
lw	$a1, 12($sp) 		# $a1  = p_of_x
jal	print			# call print()
	
# SysExit()
 lw	$ra,  20($sp)		# Restore $ra
 addi 	$sp, $sp, 24 		# deallocate 6 words
 addi 	$v0, $zero, SYS_EXIT	# $v0 = SysExit() service code
 syscall 			# Call SysExit()

#-------------------------------------------------------------------------------------------------------------
# FUNCTION: int getint(string prompt)

# DESCRIPTION
# Displays the prompt string (the variable 'prompt' contains the address of the string which is defined in the
# .data section) using SysPrintStr(). Then calls SysReadInt() to read the integer the user enters. Returns the
# integer in $v0.

# PARAMETERS
# $a0 prompt (addr of string to be displayed)

# PSEUDOCODE
# function getint(string prompt) returns int
# 	int n
# 	SysPrintStr(prompt)
# 	n = SysReadInt()
# 	return n
# end function

# RETURNS
# An int in $v0 which is the integer the user typed

# STACK FRAME
# param prompt 4($sp)
# local var n 0($sp)
#-------------------------------------------------------------------------------------------------------------

getint:
addi	$sp, $sp, -8			# allocate 2 words in stack frame
sw	$a0, 4($sp)			# stores prompt in stack frame

# SysPrintStr(prompt)
lw	$a0, 4($sp)			# $a0 = prompt	
addi	$v0, $zero, SYS_PRINT_STR	# $v0 = SysPrintStr service code
syscall					# Call SysPrintInt()

# n = SysReadInt()
addi	$v0, $zero, SYS_READ_INT	# $v0 = SysReadInt service code
syscall					# Call SysReadInt
sw	$v0, 0($sp)			# n = SysReadInt()
lw	$v0, 0($sp)			# $v0 = n

addi	$sp, $sp, 8			# deallocate 2 words
jr	$ra				# return n in $v0

#-------------------------------------------------------------------------------------------------------------
# FUNCTION: void print(string msg, int n)
# DESCRIPTION:
# Displays a message string (msg contains the address of the string to be printed) using SysPrintStr(). Then
# displays the value of int variable n using SysPrintInt().

# PARAMETERS
# $a0 msg (addr of string to be displayed)
# $a1 n (value of n)

# PSEUDOCODE
# function print(string msg, int n) returns nothing
# 	SysPrintStr(msg)
# 	SysPrintInt(n)
# end function

# RETURNS
# Nothing

# STACK FRAME
# print() is a leaf procedure and does not allocate any local variables. We *could* allocate params msg and n
# in print()'s stack frame, but instead, we will optimize the code and not do that.
#-------------------------------------------------------------------------------------------------------------

print:
# SysPrintStr(msg)
addi	$v0, $zero, SYS_PRINT_STR	# $v0 = SysPrintStr service code
syscall					# Call SysPrintStr()

# SysPrintInt(n)
addi	$v0, $zero, SYS_PRINT_INT	# $v0 = SysPrintInt service code
move 	$a0, $a1			# $a0 = $a1
syscall					# Call SysPrintInt()
jr	$ra				# return 

#-------------------------------------------------------------------------------------------------------------
# FUNCTION: int evalpoly(c0, c1, c2, x)

# DESCRIPTION:
# Evaluates the 2nd-degree polynomial c2 * x^2 + c1 * x + c0 and returns the result.

# PARAMETERS
# $a0 c0
# $a1 c1
# $a2 c2
# $a3 x

# PSEUDOCODE
# function evalpoly(c0, c1, c2, x) returns int
	# int result = c2 * x^2 + c1 * x + c0
	# return result
# end function

# RETURNS
# An int in $v0 which is the result of evaluating the polynomial

# STACK FRAME
# Params c0, c2, c2, x and local variable result are all ints (words) so evalpoly()'s stack frame is five
# words which is 20 bytes.
# param x 16($sp)
# param c2 12($sp)
# param c1 8($sp)
# param c0 4($sp)
# local var result 0($sp)
#-------------------------------------------------------------------------------------------------------------

evalpoly:
addi 	$sp, $sp, -20
sw	$a0, 4($sp)	# c0 = $a0  
sw	$a1, 8($sp)	# c1 = $a1 
sw	$a2, 12($sp)	# c2 = $a2
sw	$a3, 16($sp)	# x = $a3
lw	$a3, 16($sp)	# $a3 = x
lw	$a2, 12($sp)	# $a2 = c2
mul	$t0, $a3, $a3	# $t0 = x*x
mul	$t1, $a2, $t0	# $t1 = c2*(x*x)
lw	$a1, 8($sp)	# $a1 = c1
mul	$t0, $a1, $a3	# $t0 = c1*x
add	$t0, $t1, $t0	# $t0 = c2*(x*x) + c1*x
lw	$a0, 4($sp)	# #a0 = c0
add	$t0, $t0, $a0	# $t0 = c2*(x*x) + c1*x +c0
sw	$t0, 0($sp)	# result = $t0
lw	$v0, 0($sp)	# $v0 = result
addi	$sp, $sp, 20	# deallocate 5 words
jr	$ra		# return result in $v0