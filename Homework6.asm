# Homework 6
# Christy Jacob

.data
# memory to hold input file name
fin:			.asciiz	"input.txt"
# creating buffer
readNumbers:		.space 	80
# creating memory to hold error message for when bytes read <= 0
bytesLessOrEqualZero:	.asciiz	"The bytes read were less than or equal to zero.\n"
# creating memory for array with 20 elements initialized to 0
array:			.word	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
# creating memory to store a space
space:			.asciiz	" "
# creating memory to store array before and array after message
arrayBefore:		.asciiz	"The array before:       "
arrayAfter:		.asciiz	"\nThe array after:        "
# creating memory to hold mean, integer median, float median, and standard deviation
mean:			.float	1.0
floatMedian:		.float	1.0
integerMedian:		.word	1
standardDeviation:	.float	1.0
# creating messages to print before mean, median, and standard deviation
meanMessage:		.asciiz	"\nThe mean is: "
medianMessage:		.asciiz	"\nThe median is: "
standardDeviationMsg:	.asciiz	"\nThe standard deviation is: "

.text
# main function
main:
	# calling function to read integers (string) from file into a buffer 
	jal	 readText
	
	# if bytes read is 0 or less print an error message and exit
	sle $t1, $s2, $zero
	bne $t1, $zero, errorAndExit
	
	# calling function  to convert string numbers to integers and store in an array
	la	$a0, array
	li	$a1, 20
	la	$a2, readNumbers
	jal	extractIntegers
	
	# calling function to print array of ints before selection sort
	jal 	printArrayBefore
	
	# calling function for selection sort
	jal	selectionSort
	
	# calling function to print array of ints after selection sort
	jal 	printArrayAfter
	
	# calling function to compute mean
	la	$a0, array
	li	$a1, 20
	jal 	computeMean
	
	# calling function to compute median
	la	$a0, array
	li	$a1, 20
	jal 	computeMedian
	
	# if flag is 0, the array has an even length and you must print the float version of the median
	beq	$v1, $zero, evenLengthPrintFloatMedian
	
	# if flag is 1, the array has an odd length and you must print the integer version of the median
	sw	$v0, integerMedian
	
	# print median message then print median
	li	$v0, 4
	la	$a0, medianMessage
	syscall
	
	li	$v0, 1
	lw	$a0, integerMedian
	syscall
	
	# continue executing main, skipping over float version of median being printed
	j 	continueMain

# prinitng the float version of mean and continuing main
evenLengthPrintFloatMedian:
	# print median message then print median
	li	$v0, 4
	la	$a0, medianMessage
	syscall
	
	swc1	$f0, floatMedian
	li	$v0, 2
	lwc1	$f12, floatMedian
	syscall
	
continueMain:	
	# calling function to compute standard deviation
	la	$a0, array
	li	$a1, 20
	jal	 computeStandardDeviation
	
	# saving standard deviation
	swc1	$f6, standardDeviation
	
	# printing standard deviation message then standard deviation
	li	$v0, 4
	la	$a0, standardDeviationMsg
	syscall
	
	li	$v0, 2
	lwc1	$f12, standardDeviation
	syscall
	
	# exiting program
	j	exit
	
# read input function
readText:
	# opening input file
	li	$v0, 13
	la	$a0, fin
	li	$a1, 0
	li	$a2, 0
	syscall
	
	# saving file descriptor
	move	$s2, $v0
	
	# reading from input file
	li	$v0, 14
	move	$a0, $s2
	la	$a1, readNumbers
	li	$a2, 80
	syscall
	
	# saving bytes read
	move	$s2, $v0
	
	jr	$ra
	
# function to extract integers
extractIntegers:
	# extracting integers and storing them in an array
	move	$t0, $a0
	move	$t2, $a2
	# registers holding 57 and 48 to check for greater than 57 or less than 48 
	li 	$t6, 57
	li	$t7, 48
	li	$t4, 10 # register holding 10 to oheck for new line
	li	$t5, 0	# accumulator register
	
# loop to determine extracted numbers
getNumbers:
	# load the byte and if ASCII code not 0 or 10(newline character) and if within 48-57, continue getting digits till newline character
	lb	$t3, ($t2)
	addi	$t2, $t2, 1
	beq	$t3, $t4, storeNumber
	beq	$t3, $zero, returnFromExtracting
	slt	$t8, $t3, $t7
	bne	$t8, $zero, getNumbers
	sgt	$t8, $t3, $t6
	bne	$t8, $zero, getNumbers
	# subtract 48 from ASCII code
	addi	$t3, $t3, -48
	# multiply accumulator register by 10 and add current digit to it
	mult	$t5, $t4
	mflo	$t5
	add	$t5, $t5, $t3
	# loop until finding the newline character or \0
	j	getNumbers
	
# return to main after finished extracting
returnFromExtracting:
	sw	$t5, ($t0)
	jr	$ra

# store number if current byte is newline character
storeNumber:
	# store accumulator register
	sw	$t5, ($t0)
	# reset accumulator register
	li	$t5, 0
	# update array element
	addi	$t0, $t0, 4
	j	getNumbers
	
# function to print the array before selection sort
printArrayBefore:
# storing address of array in $t0 and 20 in $t1 to keep track of how many elements are left to print
	la	$t0, array
	li	$t1, 20

	# printing out array before message
	li	$v0, 4
	la	$a0, arrayBefore
	syscall
	
# loop to print each element of array
printLoop1:
	# printing each element of the array followed by a space
	li	$v0, 1
	lw	$a0, ($t0)
	syscall
	
	li	$v0, 4
	la	$a0, space
	syscall
	
	# updating to next element and decreasing number of element left to print
	addi	$t0, $t0, 4
	addi	$t1, $t1, -1
	# looping as long as there are elements left to print
	bne	$t1, $zero, printLoop1
	# return to main once finished printing all the elements
	jr 	$ra
	
# function to print the array after selection sort
printArrayAfter:
# storing address of array in $t0 and 20 in $t1 to keep track of how many elements are left to print
	la	$t0, array
	li	$t1, 20

	# printing out array before message
	li	$v0, 4
	la	$a0, arrayAfter
	syscall
	
# loop to print each element of array
printLoop2:
	# printing each element of the array followed by a space
	li	$v0, 1
	lw	$a0, ($t0)
	syscall
	
	li	$v0, 4
	la	$a0, space
	syscall
	
	# updating to next element and decreasing number of element left to print
	addi	$t0, $t0, 4
	addi	$t1, $t1, -1
	# looping as long as there are elements left to print
	bne	$t1, $zero, printLoop2
	# return to main once finished printing all the elements
	jr 	$ra
	
selectionSort:
	# storing address of array in $t0 and 20 in $t1 to keep track of how many elements are left to print
	la	$t0, array
	li	$t1, 20		# 20 is number of elements
	sll	$t1, $t1, 2	# $t1 times 4 to hold last address
	add	$t1, $t1, $t0	# $t1 holds last address
	la	$t2, array

# update the position of the next unsorted element
findLeastElement:
	lw	$t4, ($t0)	# first unsorted element is first minimum
# loop to find the new least element to put next in the sorted part of array
loopLeastElement:	
	# load current element to check if it is the smallest
	lw	$t3, ($t2)
	slt	$t5, $t3, $t4
	bne	$t5, $zero, updateMinimum
	addi	$t2, $t2, 4 # go to next element
	beq	$t1, $t2, swapElements # if on the last element, update the least element
	j	loopLeastElement
	
# update $t4 to the new minimum if a number smaller than current minimum is found
updateMinimum:
	move	$t4, $t3	# $t4 holds the smallest element
	move	$t6, $t2	# $t6 holds address of smallest element
	addi	$t2, $t2, 4	# go to next element
	beq	$t1, $t2, swapElements # if on the last element, update the least element
	j	loopLeastElement

# swap elements if the first unsorted element isn't the smallest element left
swapElements:
	lw	$t7, ($t0)
	beq	$t7, $t4, updateNextElement
	
# loop to move up the position of the elements before minimum if minimum isn't first unsorted element
loopSwapElements:
	addi	$t9, $t6, -4
	lw	$t8, ($t9)
	sw	$t8, ($t6)
	addi	$t6, $t6, -4
	beq	$t6, $t0, updateNextElement
	j	loopSwapElements
	
# add minimum to sorted list and update to next element in the selection sort
updateNextElement:
	sw	$t4, ($t0)
	addi	$t0, $t0, 4
	move	$t2, $t0
	beq	$t1, $t0, returnSelectionSort # if on the last element in sort, return function
	j	findLeastElement

# once finished with sort, return to main
returnSelectionSort:
	jr	$ra
	
# print error and exit function
errorAndExit:
	# print eroor message if bytes read is less than or equal to 0
	li	$v0, 4
	la	$a0, bytesLessOrEqualZero
	syscall
	
# function to compute single precision mean
computeMean:
	# move array address to $t0 and array size to $t1
	move	$t0, $a0
	move	$t1, $a1
	li	$t3, 0	# initialize accumulator to 0

# loop to accumulate sum of array elements
computeSum:
	lw	$t2, ($t0)
	add	$t3, $t3, $t2
	addi	$t1, $t1, -1
	addi	$t0, $t0, 4
	beq	$t1, $zero, printMean
	j	computeSum

# printing mean after dividing sum by 20
printMean:
	# computing mean and storing it in memory
	mtc1	$t3, $f0
	cvt.s.w	$f0, $f0
	li	$t1, 20
	mtc1	$t1, $f2
	cvt.s.w	$f2, $f2
	div.s	$f4, $f0, $f2
	swc1	$f4, mean
	
	# print message then print mean
	li	$v0, 4
	la	$a0, meanMessage
	syscall
	
	li	$v0, 2
	lwc1	$f12, mean
	syscall
	
	# return to main after printing the mean
	jr	$ra
	
# function to compute single precision median
computeMedian:
	# compute median based off whether the length is odd or even
	move	$t0, $a0
	move	$t1, $a1
	li	$t3, 2
	div	$t1, $t3
	mfhi	$t2
	mflo	$t4
	sll	$t4, $t4, 2
	add	$t4, $t4, $t0
	lw	$t5, ($t4)
	move	$v0, $t5
	# if length mod 2 is not 0, just get the element at the quotient to be the median
	bne	$t2, $zero, returnAfterGettingIntegerMedian
	# if length mod 2 is 0, average the element at the quotient and the one before
	mtc1	$t5, $f0
	cvt.s.w	$f0, $f0
	addi	$t4, $t4, -4
	lw	$t5, ($t4)
	mtc1	$t5, $f2
	cvt.s.w	$f2, $f2
	add.s	$f0, $f2, $f0
	mtc1	$t3, $f2
	cvt.s.w	$f2, $f2
	div.s	$f0, $f0, $f2
	# median is stored in $f0 if even length
	li	$v0, 0
	jr 	$ra
	
returnAfterGettingIntegerMedian:
	# return to main after getting the median
	li	$v0, 1
	jr	$ra

# function to compute the single precision standard deviation
computeStandardDeviation:
# registers to hold mean, address of array, and number of elements in array
	lwc1	$f0, mean
	la	$t0, array
	li	$t1, 20
	# initialize accumulator to 0
	mtc1	$zero, $f6
	cvt.s.w	$f6, $f6

# loop to calculate sum of differences from mean of all the array elements
loopDifferenceFromMean:
	# loading current array element and converting it to single precision
	lw	$t2, ($t0)
	mtc1	$t2, $f2
	cvt.s.w	$f2, $f2	
	sub.s	$f4, $f2, $f0	# computing current array element minus array average
	mul.s	$f4, $f4, $f4	# computing (ri-ravg) squared
	add.s	$f6, $f6, $f4	# adding to accumulator
	# update to next array element and decrease number of elements left to calculate
	addi	$t0, $t0, 4
	addi	$t1, $t1, -1
	beq	$t1, $zero, returnAfterGettingStandardDeviation
	j	loopDifferenceFromMean
	
# return to main after getting standard deviation
returnAfterGettingStandardDeviation:
	# using n-1 as a float
	li	$t0, 19
	mtc1	$t0, $f0
	cvt.s.w	$f0, $f0
	# dividing by n-1
	div.s 	$f6, $f6, $f0
	# getting standard deviation by using square root
	sqrt.s	$f6, $f6
	jr	$ra
	
# exit function
exit:
	li	$v0, 10
	syscall
