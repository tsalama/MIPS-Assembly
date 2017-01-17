#***************************************************************************************************
#  FILE:  hw03-4.s
#
#  DESCRIPTION
#  Outputs the GCD of user-inputted values a and b

#  AUTHOR INFO
#  Tarek Salama (tsalama@asu.edu)
#*********************************************************************************************************

#=========================================================================================================
# System Call Equivalents
#=========================================================================================================
.eqv SYS_EXIT 10
.eqv SYS_PRINT_INT 1
.eqv SYS_PRINT_STR 4
.eqv SYS_READ_INT 5
.eqv SYS_READ_STR 8

#=========================================================================================================
# DATA SECTION
#=========================================================================================================
.data

a:	    .word	0		# int a = 0
b:	    .word  	0		# int b = 0
x:          .word       0		# int x = 0
y:          .word       0		# int y = 0
m:          .word       0		# int m = 0
gcd:	    .word       0		# int gcd = 0

a_prompt:   .asciiz 	"Enter a? "	# char *a_prompt = "Enter a? "
b_prompt:   .asciiz	"Enter b? "	# char *b_prompt = "Enter b? "
gcd_1:      .asciiz	"\nGCD("	# char *gcd_1 = "\nGCD("
gcd_2:      .asciiz	", "		# char *gcd_2 = ", "
gcd_3:      .asciiz	") is "		# char *gcd_3 = ") is "

#=========================================================================================================
# TEXT SECTION
#=========================================================================================================
.text
main:

# INPUT
# SysPrintStr("Enter a? ")
addi	$v0, $zero, SYS_PRINT_STR	# $v0 = SysPrintStr service code
la	$a0, a_prompt			# $a0 = addr of a_prompt
syscall                                 # Call SysPrintStr()

# a = SysReadInt();
addi	$v0, $zero, SYS_READ_INT 	# $v0 = SysReadInt code
syscall 				# Call SysReadInt()
la	$s0, a				# $s0 = addr of a
sw	$v0, 0($s0)			# a = SysReadInt()


# SysPrintStr("Enter b? ")
addi	$v0, $zero, SYS_PRINT_STR	# $v0 = SysPrintStr service code
la	$a0, b_prompt               	# $a0 = addr of b_prompt
syscall                                 # Call SysPrintStr()

# b = SysReadInt();
addi	$v0, $zero, SYS_READ_INT 	# $v0 = SysReadInt code
syscall 				# Call SysReadInt()
la	$s0, b				# $s0 = addr of b
sw	$v0, 0($s0) 			# b = SysReadInt()



# GCD
# load
la	$s0, a				# $s0 = &a		
lw	$s0, 0($s0)			# $s0 = a
la	$s1, b				# $s1 = &b		
lw	$s1, 0($s1)			# $s1 = b
la  	$s2, x                		# $s2 = &x
lw	$s2, 0($s2)			# $s2 = x
la      $s3, y                		# $s3 = &y
lw	$s3, 0($s3)			# $s3 = y
la	$s4, m				# $s4 = &m
lw	$s4, 0($s4)			# $s4 = m
la	$s5, gcd			# $s5 = &gcd
lw	$s5, 0($s5)			# $s5 = gcd

# a = abs(a), b = abs(b)
        slt $t0, $zero, $s0       	
        bne $t0, $zero, end  		# if a is positive, goto end
        sub $s0, $zero, $s0      	# a = 0 - a
end:
        slt $t1, $zero, $s1      	
        bne $t1, $zero, end_1  		# if b is positive, goto end_1
        sub $s1, $zero, $s1      	# b = 0 - b
end_1:

# x = max(a, b), y = min(a, b)
	slt 	$at, $s0, $s1		
	bne 	$at, $zero, false_clause 	# if a < b goto false_clause
	addi	$s2, $s0, 0 			# x = a
	addi	$s3, $s1, 0 			# y = b
	j end_if 				# Jump over false clause
false_clause: 					# Come here if a < b	
	addi	$s2, $s1, 0 			# x = b      
	addi	$s3, $s0, 0 			# y = a
end_if: 					# True clause jumps here

# GCD
	bne 	$s3, $zero, false_clause_1 	# if y != 0, then go to false clause_1
	addi	$s5, $s2, 0 			# gcd = x
	j end_if_1 				# Jump over false clause
false_clause_1: 				# Come here if y != 0
	div	$s2, $s3			# HI <- x % y
	mfhi	$s4				# m = x % y
	loop_begin:
		beq 	$s4, $zero, end_loop 	# if m == 0 then drop out of loop
		addi 	$s2, $s3, 0 		# x = y
		addi 	$s3, $s4, 0 		# y = m
		div	$s2, $s3		# HI <- x % y
		mfhi	$s4			# m = x % y					
		j loop_begin 			# Continue looping
	end_loop: 				# Come here when m == 0	
	addi	$s5, $s3, 0 			# gcd = y	
end_if_1: 					# True clause jumps here



# OUTPUT
# SysPrintString("\nGCD(")
la	$a0, gcd_1			# $a0 = addr of gcd_1
addi	$v0, $zero, SYS_PRINT_STR	# $v0 = SystPrintStr() code
syscall					# Call SysPrintString(gcd_1)

# SysPrintInt(a)
la	$a0, a				# $a0 = &a
lw	$a0, 0($a0)			# $a0 = a
addi    $v0, $zero, SYS_PRINT_INT       # $v0 = system code for PrintInt
syscall                                 # Call PrintInt(a)

# SysPrintString(", ")
la	$a0, gcd_2			# $a0 = addr of gcd_2
addi	$v0, $zero, SYS_PRINT_STR	# $v0 = SystPrintStr() code
syscall					# Call SysPrintString(gcd_2)

# SysPrintInt(b)
la	$a0, b				# $a0 = &b
lw	$a0, 0($a0)			# $a0 = b
addi    $v0, $zero, SYS_PRINT_INT       # $v0 = system code for PrintInt
syscall                                 # Call PrintInt(b)

# SysPrintString(") is ")
la	$a0, gcd_3			# $a0 = addr of gcd_3
addi	$v0, $zero, SYS_PRINT_STR	# $v0 = SystPrintStr() code
syscall					# Call SysPrintString(gcd_3)

# SysPrintInt(gcd)
addi    $v0, $zero, SYS_PRINT_INT       # $v0 = system code for PrintInt
move	$a0, $s5			# $a = gcd
syscall                                 # Call PrintInt(gcd)



# SysExit()
    addi    $v0, $zero, SYS_EXIT       	# $v0 = SysExit() service code
    syscall                             # Call SysExit()
