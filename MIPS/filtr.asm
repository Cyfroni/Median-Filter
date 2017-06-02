#abc

.data
msg1:				.asciiz	"Input file name:\n"
header: 			.space   54 	
file:				.space	128 
#file:				.asciiz	"file.bmp"	
msg2:				.asciiz	"Output file name:\n"
#result: 			.asciiz	"result.bmp"
result: 			.space  128
#alignment1: 			.asciiz	"#############################"
pix:				.space	3
#alignment2: 			.asciiz	"##########################"
pixels:				.space  9
#alignment3: 			.asciiz	"########"
buff:				.space  5760 #640 * 3 * 3


enter:				.asciiz "\n"
err:				.asciiz "error\n"


#	$s0 - input file descriptor
#   	$s1 - output file descriptor
#   	$s2 - (width * 3) + padding
#	$s3 - (height - 1)
#   	$s4 - actual row
#	$s5 - actual column
#	$s6 - bytes of padding in each row
#   	$s7 - width_max = 1920 = 640 * 3

.text
main:
	li $s7, 1920

	#j debug
			
	#print msg1
	li		$v0, 4
	la		$a0, msg1	#"Input file name:\n"
	syscall
	
	#read filename
	li		$v0, 8
	la		$a0, file
	li		$a1, 128	
	syscall
	
	#print msg2
	li		$v0, 4
	la		$a0, msg2	#"Output file name:\n"
	syscall
	
	#read result name
	li 		$v0, 8
	la 		$a0, result
	li 		$a1, 128		
	syscall
	
	#remove trailing newline
	li 		$t0, '\n'					
	la		$t1, file
	li		$t2, 0
	
search:
	add		$t1, $t1, 1
	lbu		$t3, ($t1) 
	bne		$t3, $t0, search
	sb		$t2, ($t1)
	
	la		$t1, result
search2:
	add		$t1, $t1, 1
	lbu		$t3, ($t1) 
	bne		$t3, $t0, search2
	sb		$t2, ($t1)	
	
#debug:
	
	#open input file
	li		$v0, 13
	la		$a0, file
	li 		$a1, 0
	li		$a2, 0
	syscall

	blt		$v0, 0, err
	move		$s0, $v0
	
	#read header
	li		$v0, 14
	move		$a0, $s0
	la		$a1, header
	li		$a2, 54
	syscall
	
	#save the width
	lw 		$s2, header+18	
	mul		$s2, $s2, 3
	
	#calculate padding
	li		$t0, 4
	div		$s2, $t0 
	mfhi		$s6
	
	sub		$s6, $t0, $s6
	
	div		$s6, $t0 
	mfhi		$s6
	
	add		$s2, $s2, $s6
	
	
	#save height
	lw		$s3, header+22
	
	#store the size of the data section of the image
	lw		$t0, header+34
	
	#check data	
	mul		$t1, $s2, $s3
	bne 		$t1, $t0, error	
	bgt		$s2, $s7, error

	add		$s3, $s3, -1	
	
	#load first row
	li		$v0, 14
	move		$a0, $s0
	la		$a1, buff
	move		$a2, $s2
	syscall
	
	#load second row
	la		$t0, buff
	add		$t0, $t0, $s7
	
	li		$v0, 14
	move		$a0, $s0
	move		$a1, $t0
	move		$a2, $s2
	syscall
	
	#open output file
	li		$v0, 13
	la		$a0, result
	li 		$a1, 1
	li		$a2, 0
	syscall
	
	move		$s1, $v0
	
	#write header to output file
	li		$v0, 15
	move		$a0, $s1
	la		$a1, header
	li		$a2, 54
	syscall
	
	#write first row to output file
	li		$v0, 15
	move		$a0, $s1
	la		$a1, buff
	move		$a2, $s2
	syscall	
	
	#initiate row counter
	li $s4, 1
	
add_new_row:
	#increase row counter
	add  		$s4, $s4, 1
	
	#find place for new row
	li		$t0, 3
	div		$s4, $t0 
	mfhi		$t0
	
	#load new row
	la		$t1, buff
	mul		$t0, $t0, $s7
	add		$t1, $t1, $t0
	
	li		$v0, 14
	move		$a0, $s0
	move		$a1, $t1
	move		$a2, $s2
	syscall
	
	#write first pixel of previous "new row" to output file
	add		$t0, $s4, -1
	
	li		$t1, 3
	div		$t0, $t1 
	mfhi		$t0
	
	la		$t1, buff
	mul		$t0, $t0, $s7
	add		$t1, $t1, $t0
	
	li		$v0, 15
	move		$a0, $s1
	move		$a1, $t1
	li		$a2, 3
	syscall
	
	#initiate column counter
	li		$s5, 3
	
writing:
	
	la		$t1, buff
	
	#load 9 bytes of Red color
	
	add		$t1, $t1, $s5

	lbu		$t2, -3($t1)			
	sb		$t2, pixels
	lbu		$t2, ($t1)			
	sb		$t2, pixels+1
	lbu		$t2, 3($t1)			
	sb		$t2, pixels+2
	
	add		$t1, $t1, $s7
	
	lbu		$t2, -3($t1)			
	sb		$t2, pixels+3
	lbu		$t2, ($t1)				
	sb		$t2, pixels+4
	lbu		$t2, 3($t1)			
	sb		$t2, pixels+5
	
	add		$t1, $t1, $s7
	
	lbu		$t2, -3($t1)			
	sb		$t2, pixels+6
	lbu		$t2, ($t1)			
	sb		$t2, pixels+7
	lbu		$t2, 3($t1)			
	sb		$t2, pixels+8
	
	jal	find_median
	sb		$t3, pix
	
	#load 9 bytes of Green color
	
	sub		$t1, $t1, $s7
	sub		$t1, $t1, $s7
	add		$t1, $t1, 1
	
	lbu		$t2, -3($t1)			
	sb		$t2, pixels
	lbu		$t2, ($t1)			
	sb		$t2, pixels+1
	lbu		$t2, 3($t1)			
	sb		$t2, pixels+2
	
	add		$t1, $t1, $s7
	
	lbu		$t2, -3($t1)			
	sb		$t2, pixels+3
	lbu		$t2, ($t1)			
	sb		$t2, pixels+4
	lbu		$t2, 3($t1)			
	sb		$t2, pixels+5
	
	add		$t1, $t1, $s7
	
	lbu		$t2, -3($t1)			
	sb		$t2, pixels+6
	lbu		$t2, ($t1)			
	sb		$t2, pixels+7
	lbu		$t2, 3($t1)			
	sb		$t2, pixels+8
	
	jal	find_median
	sb		$t3, pix+1
	
	#load 9 bytes of Blue color
	
	sub		$t1, $t1, $s7
	sub		$t1, $t1, $s7
	add		$t1, $t1, 1
	
	lbu		$t2, -3($t1)			
	sb		$t2, pixels
	lbu		$t2, ($t1)			
	sb		$t2, pixels+1
	lbu		$t2, 3($t1)			
	sb		$t2, pixels+2
	
	add		$t1, $t1, $s7
	
	lbu		$t2, -3($t1)			
	sb		$t2, pixels+3
	lbu		$t2, ($t1)			
	sb		$t2, pixels+4
	lbu		$t2, 3($t1)			
	sb		$t2, pixels+5
	
	add		$t1, $t1, $s7
	
	lbu		$t2, -3($t1)			
	sb		$t2, pixels+6
	lbu		$t2, ($t1)			
	sb		$t2, pixels+7
	lbu		$t2, 3($t1)			
	sb		$t2, pixels+8
	
	jal	find_median
	sb		$t3, pix+2
	

	
	#write 1 pixel to output file
	li		$v0, 15
	move		$a0, $s1
	la		$a1, pix
	li		$a2, 3
	syscall
	
	add		$s5, $s5, 3
	
	#check if row ended
	add		$t3, $s5, 3
	add		$t3, $t3, $s6	
	blt		$t3, $s2, writing

	#write last pixel of row and padding to output file
	add		$t0, $s4, -1
	
	li		$t1, 3
	div		$t0, $t1 
	mfhi		$t0
	
	la		$t1, buff
	mul		$t0, $t0, $s7
	add		$t1, $t1, $t0
	add		$t1, $t1, $s2
	add		$t2, $s6, 3
	sub		$t1, $t1, $t2
	
	li		$v0, 15
	move		$a0, $s1
	move		$a1, $t1
	move		$a2, $t2
	syscall

	#check if file ended
	blt		$s4, $s3, add_new_row 	#height - 1
	
	#write last row and go to end
	li		$t0, 3
	div		$s4, $t0 
	mfhi		$t0
	
	la		$t1, buff
	mul		$t0, $t0, $s7
	add		$t1, $t1, $t0
	
	li		$v0, 15
	move		$a0, $s1
	move		$a1, $t1
	move		$a2, $s2
	syscall
	
	j end
	
###################################################################
find_median:
	li 		$t0, 255	#biggest

	li		$t8, 0		#counter to 5 (5th smallest is median)
next_smallest:
	add		$t8, $t8, 1
	li		$t3, 255	#smallest
	la		$t2, pixels	
	sub		$t2, $t2, 1
	li		$t9, 0		#counter to 8 (9 bytes to compare)
find_smallest:
	
	
	beq		$t9, 9	smallest_found
	add		$t9, $t9, 1
	add		$t2, $t2, 1 
	lbu 		$t4, ($t2) 		
	blt		$t3, $t4, find_smallest
	move		$t3, $t4	#smallest's value
	move		$t5, $t2 	#smallest's address 
	j		find_smallest


smallest_found:
	sb		$t0, ($t5)	#replace smallest with biggest
	ble		$t8, 4, next_smallest 
	 
	#median is in $t3
	jr		$ra	
	
error:
	la   $a0, err
	li   $v0, 4
	syscall
	
	la   $a0, enter
	li   $v0, 4
	syscall
	
	lbu   $a0, header+34
	li   $v0, 1
	syscall
	
	la   $a0, enter
	li   $v0, 4
	syscall
	
end:
	move		$a0, $s0
	li		$v0, 16
	syscall
	
	move $a0, $s2
	li   $v0, 1
	syscall
	
	la   $a0, enter
	li   $v0, 4
	syscall
	
	add	$s3, $s3, 1
	
	move $a0, $s3
	li   $v0, 1
	syscall
	
	la   $a0, enter
	li   $v0, 4
	syscall
	############
