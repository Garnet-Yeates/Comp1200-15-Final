;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This program asks the user to enter an operation and then performs that operation with SRC1 and SRC2 as inputs;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ORIG x4000
GOTDIGITS AND R0,R0,#0
	ADD R0,R0,#10
	TRAP x21 ; Print a line break before the third message
	
	LEA R0,MSG3 ; Tell the user to enter the operation
	PUTS

	GETC
	out
	AND R3,R3,#0 ; Move last entered char ASCII to R3
	ADD R3,R3,R0
	
	AND R0,R0,#0 ; Print a line break so the next printed thing is on a new line
	ADD R0,R0,#10
	TRAP x21

	AND R1,R1,#0 ; Clear R1 because all operation results will be into R1
	
	LD R2,ASCII_ADD
	ADD R0,R3,R2
	BRz ADDITION
	LD R2,ASCII_SUB
	ADD R0,R3,R2
	BRz SUBTRACTION
	LD R2,ASCII_MUL ; Figures out what operation should be done
	ADD R0,R3,R2
	BRz MULTIPLICATION
	LD R2,ASCII_DIV
	ADD R0,R3,R2
	BRz DIVISION
	LD R2,ASCII_POW
	ADD R0,R3,R2
	BRz POWER
	LD R2,ASCII_MOD
	ADD R0,R3,R2
	BRz MODULO
	
	LEA R0,ERR_OP ; If it didn't jump to one of the operation labels by now, there was user error so loop back
	PUTS
	BRnzp GOTDIGITS
	
	; Store result of each operation in R1
	
	ADDITION
		ADD R1,R4,R6
		BRnzp OUTPUT
	
	SUBTRACTION
		NOT R4,R4
		ADD R4,R4,#1
		ADD R1,R4,R6
		BRnzp OUTPUT
	
	DIVISION ; R6 / R4
		ADD R4,R4,#0 ; Check if R4 is 0
		BRnp #3
		AND R0,R0,#0 ; If R4 is 0 then they are dividing by zero so jump to NAN block
		ADD R0,R0,#-1 ; To jump to this block we need to set R0 to -1 so the output program knows that we are printing 'undefined'
		BRnzp OUTPUT

		NOT R4,R4
		ADD R4,R4,#1
		AND R1,R1,#0 ; R1 is going to be our counter
		DIVIDE ADD R1,R1,#1
			ADD R6,R6,R4
			BRzp DIVIDE
		ADD R1,R1,#-1 ; R1 will have the amount of times R4 goes into R6
		BRnzp OUTPUT
		
	MODULO ; R6 % R4
		ADD R4,R4,#0 ; Check if R4 is 0
		BRnp #3
		AND R0,R0,#0 ; If R4 is 0 then they are dividing by zero so jump to NAN block
		ADD R0,R0,#-1 ; To jump to this block we need to set R0 to -1 so the output program knows that we are printing 'undefined'
		BRnzp OUTPUT

		NOT R4,R4
		ADD R4,R4,#1
		AND R1,R1,#0 ; R1 is going to be our counter
		MODDIV ADD R1,R1,#1
			ADD R6,R6,R4
			BRzp MODDIV
		NOT R4,R4
		ADD R4,R4,#1
		ADD R1,R6,R4 ; Undo the last operation on R6 and move it into R1 because it is our mod output
		BRnzp OUTPUT
			
	MULTIPLICATION
		ADD R0,R6,#0 ; To check if R6 is 0
		BRz#4 ; 0 times anything is 0 so skip the multiply loop if INPUT1 is 0
		MULTIPLY2 ADD R1,R1,R4 ;
			ADD R6,R6,#-1 ; decrement our counter 
			BRp MULTIPLY2 ; continue until the 2nd num is 0
		BRnzp OUTPUT ; When done multiplying, jump to output block
		AND R1,R1,#0 ; If the multiply loop was skipped that means the answer should just be 0
		BRnzp OUTPUT ; Jump to output block
		
	POWER
		ADD R0,R4,#0 
		BRz ZERO_POWER ; If they put 0 for the power (R4) jump to ZERO_POWER
		ADD R0,R4,#-1
		BRz ONE_POWER ; If they put 1 for the power (R4) jump to ONE_POWER
		ADD R4,R4,#-1 ; R4 is going to be how many times R6 goes through the power loop. It is subtracted by 1 because each run of the power loop does R6*R6, so a power of 2 would need to go through the power loop once
		AND R3,R3,#0
		ADD R3,R3,R6 ; Copy R6 into R3 as well for multiplication
		AND R5,R5,#0 ; Empty R5
		ADD R5,R5,R6 ; Put another clone of R6 into R5 so it can be copied to R3 after R3 gets to 0
		POWER_LOOP ; In this loop, R6 is multiplied by R6, R4 times
			AND R1,R1,#0 ; Clear R1 each time to store the result of each multiplication
			MULTIPLY3
				ADD R1,R1,R6 ; Continually add R6 to R1
				ADD R3,R3,#-1 ; Counter--. Before each run, Counter will be filled with whatever value R6 was originally
				BRp MULTIPLY3 ; Continue until the counter runs out
			ADD R3,R3,R5 ; Refresh the counter using the clone of the original R6 that we put into R5
			AND R6,R6,#0 ; Clear R6
			ADD R6,R6,R1 ; Now, the number that we are multiplying by R5/INPUT1 is going to be the result of the last multiplication.
				         ; So if INPUT1 was 4 and INPUT2 was 3 it would do 4x4 = 16, then that 16 is going to be what you multiply by 4 next, so 16x4 = 64...
			ADD R4,R4,#-1 ; Decrement the POWER_LOOP counter
			BRp POWER_LOOP
		BRnzp OUTPUT
		
		ZERO_POWER
			ADD R1,R1,#1
			BRnzp OUTPUT
		ONE_POWER
			ADD R1,R1,R6
			BRnzp OUTPUT
			
	OUTPUT
		LD R5,PART_C_ADDRESS
		JSRR R5
	
DONE HALT
ASCII_ADD .FILL #-43
ASCII_SUB .FILL #-45
ASCII_MUL .FILL #-42
ASCII_DIV .FILL #-47
ASCII_POW .FILL #-94
ASCII_MOD .FILL #-37
MSG3 .STRINGZ "Enter an operation ( + | - | / | * | ^ | % ): "
ERR_OP .STRINGZ "Please enter a valid operation"
PART_C_ADDRESS .FILL x5000
.END