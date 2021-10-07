.ORG 0
; Stores the value of count which can vary from 0-24
; This value will be changed by the right button
.DEF COUNT = R16 
LDI COUNT, 0

.DEF COUNT_MODE = R17; 0 for increment, 1 for decrement
.SET COUNT_MAX = 25; Max value is 24 but we only reset to zero once the counter has reached 25 and then we set it to 0.
LDI COUNT_MODE, 0

; Begin the code by setting up the buttons for input
; the left button of the Atmega32u4 is PD4 -- this controls increment mode
; and the right button of the Atmega32u4 is PF6 -- this button actually increments/decrements


CBI DDRD, 4 ; Left Button
SBI PORTD, 4
CBI DDRF, 6 ; Right Button
SBI PORTF, 6
SBI DDRC, 6 ; Set speaker as output

main:
	SBIC PIND, 4 ; Check if left button press
	RCALL changeMode ; If so, then change COUNT_MODE

	SBIC PINF, 6 ; Check if right button press
	RCALL counter ; If so, count up or down depending on COUNT_MODE


	; LED light subroutine
	RCALL LED
	RJMP main

changeMode:
	LDI R30, 0 ; To compare against COUNT_MODE, 0 increment and 1 decrement

	; De-bouncing solution
	DEBOUNCEDELAY1:
        SBIC PIND, 4; If the bit is cleared then the button is no longer being pushed and we return
        RJMP DEBOUNCEDELAY1; else we continue this loop until it is

	CP COUNT_MODE, R30 ; Checks to see if the current COUNT_MODE is positive
	BREQ negative ; If it is, it needs to be changed to negative

	LDI COUNT_MODE, 0 ; If it is negative, then it needs to be changed to positive

	RET
	
	negative:
		LDI COUNT_MODE, 1
	
	RET


; Debugging
longDelay:
	LDI R28, 20
		loop4: LDI R29, 100
			loop5: LDI R30, 100
				loop6: NOP
					   NOP
				       NOP
				       NOP
				       NOP
				       NOP
				       DEC R30
				       BRNE loop6
			    DEC R29
			    BRNE loop5
		DEC R28
		BRNE loop4
	RET


counter:
	LDI R28, 100 ; For playing sound loop
	LDI R18, 25 ; To compare against count
	LDI R30, 0 ; To see if COUNT_MODE is positive & to compare against count

	DEBOUNCEDELAY2:
        SBIC PINF, 6; If the bit is cleared then the button is no longer being pushed and we return
        RJMP DEBOUNCEDELAY2; else we continue this loop until it is

	CP COUNT_MODE, R30 ; Check if COUNT_MODE is positive. Else, COUNT_MODE is negative (only has two states)
	BREQ increment

	DEC COUNT
	CP COUNT, R27 ; To see if we just decremented from 0
	BRMI minValue

	RET

	minValue:
		LDI COUNT, 24
		soundLoop1:
			RCALL minValueSound
			DEC R28
			BRNE soundLoop1
	RET

	increment:
		INC COUNT
		CP COUNT, R18
		BRSH maxValue
	RET

	maxValue:
		LDI COUNT, 0
		soundLoop2:
			RCALL maxValueSound
			DEC R28
			BRNE soundLoop2
	RET


; For debugging. Delete later
leftButtonTest:
	SBI PORTC, 7
	RCALL longDelay
	CBI PORTC, 7
	RCALL longDelay
	SBI PORTC, 7
	RCALL longDelay
	CBI PORTC, 7
	RET


; For sound wave of minValueSound.
minValueDelay:
	LDI R29, 200 ; The values are not random, these are the values I got from the frequency calculations
	minDelay1:
		LDI R30, 5
		minDelay2:
			NOP
			DEC R30
			BRNE minDelay2
		DEC R29
		BRNE minDelay1
	RET

; For sound wave of maxValueSound
maxValueDelay:
	LDI R29, 111 ; The values are not random, these are the values I got from the frequency calculations
	maxDelay1:
		LDI R30, 8
		maxDelay2:
			DEC R30
			BRNE maxDelay2
		DEC R29
		BRNE maxDelay1
	RET

; Sound played when min value is reached. Creates square wave
minValueSound:
	SBI PORTC, 6
	RCALL minValueDelay
	CBI PORTC, 6
	RCALL minValueDelay
	RET

; Sound played when max value is reached. Creates square wave
maxValueSound:
	SBI PORTC, 6
	RCALL maxValueDelay
	CBI PORTC, 6
	RCALL minValueDelay
	RET

LED:
	LDI R20, 24
	LDI R21, 0
	LDI R22, 185
	LDI R23, 8

	CP COUNT, R20
	BREQ constant

	CP COUNT, R21
	BREQ none

	LDI R20, 255

	decrease:
		SUB R20, COUNT
		SUB R22, COUNT
		DEC R23
		BRNE decrease

	LEDLoop1:
		SBI PORTC, 7
		RCALL LEDDelay
		RCALL LEDDelay

		SBIC PIND, 4
		RET

		SBIC PINF, 6
		RET

		CBI PORTC, 7
		RCALL LEDDelay
		RCALL LEDDelay

		NOP
		NOP
		RJMP LEDLoop1

	constant:
		SBI PORTC, 7
		RET

	none:
		CBI PORTC, 7
		RET
	
LEDDelay:
	MOV R24, R20
	MOV R25, R22

	LEDDelayLoop1:
			LEDDelayLoop2:
				LDI R23, 5
				LEDDelayLoop3:
					DEC R23
					SBIC PIND, 4
					RET
					
					NOP ; To extend delay
					NOP ; To extend delay

					SBIC PINF, 6
					RET
					BRNE LEDDelayLoop3
				DEC R25
				BRNE LEDDelayLoop2
		DEC R24
		BRNE LEDDelayLoop1
	RET

/* Stanley code
CBI DDRD, 4; PD4 INPUT
SBI PORTD, 4; PULL-UP
SBI DDRC, 7; PC7 OUTPUT

 

LOOP: SBIS PIND,4
JMP LOWLED
SBI PORTC,7; HIGHLED
JMP LOOP
LOWLED: CBI PORTC,7
JMP LOOP
*/