;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This program obtains input for SRC1 and SRC2 and stores the input in R6 and R4 respectively;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ORIG x3000
AND R4,R4,#0
AND R6,R6,#0 ; R6 is where SRC1 will end up
ADD R6,R6,#-1 ; R4 is where SRC2 will end up

LEA R1,DIGITS ; R1 will be a pointer to the mem address of the 4 digits
AND R0,R0,#0
ADD R0,R0,#10
TRAP x21 ; Print a line break
LEA R0,MSG1
PUTS ; Tell the user to enter a 4 digit number

AND R2,R2,#0 ; Clear R2, which will be used for our digit count
BRnzp GETDIGITS ; Jump to GETDIGITS

GETDIGITS2
	ADD R0,R6,#1
	BRnp EXIT ; If we've already been to this step go straight to GOTDIGITS
	LEA R1,DIGITS ; Reset pointer
	AND R6,R6,#0 ; Clear R6 and move contents of R4 to R6 so we can use R4 again for the second number
	ADD R6,R6,R4 ; - ^
	AND R4,R4,#0 ; Clear R4 so the second number will be stored there after GETDIGITS runs again
	AND R2,R2,#0 ; Reset count
	AND R0,R0,#0 
	ADD R0,R0,#10
	TRAP x21 ; Print line break
	LEA R0,MSG2
	PUTS ; Tell user to enter digits for SRC2

GETDIGITS GETC
	AND R3,R3,#0 ; Clear R3 to temporarily store ASCII for line break
	ADD R3,R3,#-10 ; Store -10 in R3
	ADD R3,R3,R0
	BRnp #8
	ADD R3,R2,#0 ; Check to see if the counter is 0
	BRp #5 ; If the counter is 0 then they cant press enter yet so restart the program and print ERR msg
	out ; Print line break using out because x00A will already be in R0 because they pressed enter
	LEA R0,ERR_INPUT
	PUTS
	LD R5,START_ADDRESS 
	JSRR R5
	BRnzp DIGITSTONUM ; If the counter is not 0 and they press enter then we are done getting digits for this SRC
	out ; Echo character only if it isn't 'enter'
	
	LD R5,MIN_NUM_ASCII
	ADD R3,R0,R5
	BRn INVALID_INPUT	 ; This whole block makes sure that what they typed in is 0-9
	LD R5,MAX_NUM_ASCII
	ADD R3,R0,R5
	BRp INVALID_INPUT
	
	LD R5,NEGASCII ; Load ASCII to DIGIT offset
	ADD R0,R0,R5 ; Convert to digit
	STR R0,R1,#0 ; Store in M[R1]
	ADD R2,R2,#1 ; Count++
	ADD R1,R1,#1 ; Pointer++
	ADD R0,R2,#-4 ; Check to see if we reached max digits
	BRz DIGITSTONUM
	BRnzp GETDIGITS
	
	INVALID_INPUT ; If they didn't enter 0-9
		LD R0,TEN
		TRAP x21
		LEA R0,ERR_INPUT
		PUTS
		LD R5,START_ADDRESS
		JSRR R5
	
DIGITSTONUM
	LEA R1,DIGITS
	ADD R2,R2,#-1 ; The counter minus 1 is going to be the nth power of 10 multiplier. For instance if the user entered 200, then the count is 3 so the nth multiplier is 2 meaning the
                  ; First number is going to be multiplied by 10^2
	CONVERT_LOOP
		; Switch statement to set R3 to 1/10/100/1000 for 1's place, 10's place etc..
		ADD R0,R2,#-3
		BRnp #1
		LD R3,TENCUBED
		ADD R0,R2,#-2
		BRnp #1
		LD R3,TENSQUARED
		ADD R0,R2,#-1
		BRnp #1
		LD R3,TEN
		ADD R0,R2,#0
		BRnp #1
		LD R3,ONE
		
		LDR R0,R1,#0 ; Load the digit into R0 for a reference for addition
		MULTIPLY ADD R4,R4,R0  ; All multiple additions is added into R4
			ADD R3,R3,#-1
			BRp MULTIPLY
		
		ADD R1,R1,#1 ; Pointer++
		ADD R2,R2,#-1 ; Power--
		BRzp CONVERT_LOOP ; If the Power isn't at 0 currently (which means the pointer isnt at +3 yet) then keep looping
		BRnzp GETDIGITS2
		
EXIT
	LD R5,PART_B_ADDRESS ;load the starting address of subroutine 1 into R5.
	JSRR R5 ;now we can jump to the subroutine no matter where
		
FINISHED HALT
MIN_NUM_ASCII .FILL #-48 ; If you add this to a char and it is negative then that char is not a number
MAX_NUM_ASCII .FILL #-57 ; If you add this to a char and it is positive then that char is not a number
NEGASCII .FILL #-48 ; Add R5 to anything to convert to from ASCII to a digit
TENCUBED .FILL #1000
TENSQUARED .FILL #100
TEN .FILL #10
ONE .FILL #1
PART_B_ADDRESS .FILL x4000
START_ADDRESS .FILL x3000
MSG1 .STRINGZ "Enter up to 4 digits for SRC1:  "
MSG2 .STRINGZ "Enter up to 4 digits for SRC2:  "
ERR_INPUT .STRINGZ "Digits must be numbers"
DIGITS .BLKW #4
.END
; trap x23 in
; trap x21 out
; trap x22 prints a string after using LEA R0,<STRINGLABEL>