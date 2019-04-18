;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This program takes the result of the operation in part B and converts it into individual digits for printing then ends/restarts the whole program;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ORIG x5000
START
	ADD R0,R0,#1
	BRz NAN

OUTPUT
	LEA R0,MSG4
	PUTS ; Print 4th message
	AND R0,R0,#0 
	ADD R0,R0,#10 ; Set R0 to 10 (char for line break)
	TRAP x21 
	
	ADD R1,R1,#0
	BRzp #6
	NOT R1,R1 ; If it is negative, make it positive again
	ADD R1,R1,#1
	LD R0,ASCII_SUB
	NOT R0,R0
	ADD R0,R0,#1
	TRAP x21 ; Place a negative sign if the number is negative
	
	AND R3,R3,#0 ; R3 is our counter to see what place we are dividng by
	AND R4,R4,#0 ; If R4 is > 0 then we have to start printing 0's as placeholders
	
	NUMTODIGITS	
		ADD R0,R3,#0 
		BRnp #1
		LD R2,TENCUBED
		ADD R0,R3,#-1
		BRnp #1
		LD R2,TENSQUARED  ; Finds out if we are dividing the 1/10/100/1000's place
		ADD R0,R3,#-2
		BRnp #1
		LD R2,TEN
		ADD R0,R3,#-3
		BRnp #1
		LD R2,ONE
		
		NOT R2,R2 ; One's comp R2
		ADD R2,R2,#1 ; Two's comp R2
		AND R6,R6,#0 ; Clear R6 to be our place counter
		ADD R0,R1,R2 ; To check to see if R1-R2 < 0
		BRn PRINTDIGIT ; If the place is larger than the number than the number then it's gonna be 0 there so skip the division
		ADD R4,R4,#1 ; If it got this far there are no more leading zeros (aka we are dividing by a num <= to R1, so R4++ to let the program know that we have no more leading zeros)
		
		DIVLOOP
			ADD R6,R6,#1 ; Counter++
			ADD R1,R1,R2 ; Subtract R2 from R1 
			BRzp DIVLOOP ; Keep going until negative value appears
		ADD R6,R6,#-1 ; Counter-- to undo the last loop operation
		NOT R2,R2 ; One's comp R2
		ADD R2,R2,#1 ; Two's comp R2
		ADD R1,R1,R2 ; R1+R2 to undo the last loop operation
		
		PRINTDIGIT
			ADD R0,R4,#0
			BRz #5 ; If R4 is still zero then we still have leading zeros so skip the next 5 printing lines
			AND R0,R0,#0 ; Clear R0
			ADD R0,R0,R6 ; R6 is the digit so move it to R0
			LD R5,ASCII
			ADD R0,R0,R5 ; Convert to char
			TRAP x21 ; Output digit
			ADD R3,R3,#1 ; Add 1 to our place counter to move on to the next power of 10 division
			ADD R0,R3,#-4 ; Check to see if (Counter - 4 == 0) because if it is we are done
			BRnp NUMTODIGITS ; If not, then loop back to do the next conversion
			
			ADD R0,R4,#0 ; Just to check and see if R4 is 0
			BRnp #4 ; At this point if R4 is still zero the final result is 0, but that means no printing was done (for efficiency) so print a zero
			LD R5,ASCII
			AND R0,R0,#0 ; Set R0 to 0 because we will print '0'
			ADD R0,R0,R5  ; Convert 0 to '0'
			TRAP x21 ; Prints a '0'
			BRnzp FIN ; Now go to the end of the program
			
		NAN
			LEA R0,UNDEFINED
			PUTS
			BRnzp FIN
FIN
	LD R0,TEN ; Load line BR char into R0
	TRAP x21 ; Print line break
	LEA R0,MSG5 ; Ask if they want to re-run
	PUTS ; Ask
	GETC ; Get next input, should be y or n
	AND R3,R3,#0 ; Clear R3
	ADD R3,R3,R0 ; Move R0 to R3
	out
	LD R1,ASCII_Y
	ADD R0,R1,R3
	BRz RESTART
	LD R1,ASCII_y
	ADD R0,R1,R3
	BRz RESTART
	
	BRnzp#2
	RESTART LD R5,START_ADDRESS
	JSRR R5
	
DONE HALT
START_ADDRESS .FILL x3000
ASCII_Y .FILL #-89
ASCII_y .FILL #-121
ASCII_SUB .FILL #-45
TENCUBED .FILL #1000
TENSQUARED .FILL #100
TEN .FILL #10
ONE .FILL #1
ASCII .FILL x30 ;the mask to add to a digit to convert it to ASCII 
NEGASCII .FILL xFFD0 ;the negative version of the ASCII mask (-x30)
MSG4 .STRINGZ "The result is: "
MSG5 .STRINGZ "Would you like to re-run? (y/n): "
UNDEFINED .STRINGZ "Undefined"
.END
; trap x23 in
; trap x21 out
; trap x22 prints a string after using LEA R0,<STRINGLABEL>

; TODO add modulo
