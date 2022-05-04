;
; sevSeg16bitCounter.asm
;
; Created: 5/4/2022 1:53:54 AM
; Author : ource
;


; Replace with your application code
.include "m328pbdef.inc"

.def numH = r28;
.def numL = r18;
.def firstDigit = r17;
.def secondDigit = r27;
.def thirdDigit = r25;
.def lastDigit = r26;
.def encodedLowDigit = r23;
.def encodedHighDigit = r24;

rjmp init

.org 0x32
	encodingTable: .DB 0x7E, 0x30,0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B,0x77,0x1F,0x4E,0x3D,0x4F,0x47 ;Create array of the first ten primes in code memory
; Replace with your application code
init:
	call resetZPointer; point Z TO encoding table
	ldi r16, 0xff; set for output
	out ddrd, r16 ;Set Port A as output
	out ddrc, r16 ;Set Port B as output
	ldi numH,0x00; 7-segment high 2 byte
	ldi numL,0x00; 7-segment low 2 byte
	ldi r29,100; set for waiting next number

show:
	
	mov r19,numH; copy number numH to param of encode function
	call encode; call encode function to encode high 2 bytes 

	mov firstDigit,encodedHighDigit; to show on screen
	mov secondDigit,encodedLowDigit; to show on screen

	mov r19,numL;copy number numL to param of encode function
	call encode;call encode function to encode low 2 bytes 

	mov thirdDigit,encodedHighDigit;to show on screen
	mov lastDigit,encodedLowDigit;to show on screen
	com firstDigit ; Display is common-anode, so segments are activated by '0'
	com secondDigit ; Display is common-anode, so segments are activated by '0'
	com thirdDigit ; Display is common-anode, so segments are activated by '0'
	com lastDigit ; Display is common-anode, so segments are activated by '0'

waitforNextNumber:
	push r16; protect the value of r16

	ldi r16,0x01; set first digit
	call setDigit;
	out portd, firstDigit ; Set port A
	call wait

	ldi r16, 0x02 ; set second digit
	call setDigit;
	out portd, secondDigit ; Set port A
	call wait

	ldi r16,0x04;
	call setDigit; set third digit
	out portd, thirdDigit ; Set port A
	call wait

	ldi r16,0x08;
	call setDigit; set last digit
	out portd, lastDigit ; Set port A

	pop r16; load value of r16 back
	call wait

	dec r29; waiting for the next value
	cpi r29,0;
	brne waitforNextNumber

	call incrementCounter ; increase the value (value +1)
	rjmp show;

resetZPointer: ; set Z pointer to encodingTable
	ldi zl, low(2*encodingTable) ;multiply by 2 to use byte by byte addressing
	ldi zh, high(2*encodingTable)
	ret

setDigit:
	com r16 ;Digit is zero active
	out portc, r16 ; Set port B
	ret

wait:
	ldi r21,1
	ldi r19,5
	ldi r20,1
outerloop:
innerloop:
innerinnerloop:
	dec r20
	brne innerinnerloop
	dec r19		; decrement loop count
	brne innerloop
	dec r21
	brne outerloop
	ret

incrementCounter:
	ldi r21,0x00;
	ldi r20,0x01;
	add numL,r20;
	adc numH,r21;
	ret
	



encode: ;16-21
	mov r22,r19; copy r19 to r18 
	andi r22,0x0f; isolate lower bits

encodeLowerNibble:
	cpi r22,0; if r18 != 0 go to next element of table
	breq isZeroLow; if zero just continue
	lpm encodedLowDigit,Z+;
	lpm encodedLowDigit,Z;
	dec r22;
	cpi r22,0;
	brne encodeLowerNibble;
	call resetZPointer
encodeHigherNibble:
	mov r22,r19; cop22r19 to r18
	swap r22; change 22w and high nibble
	andi r22,0x0f; is22ate lower bits

encodeHigherNibbleLoop:
	cpi r22,0; if r122!= 0 go to next element of table
	breq isZeroHigh; if zero just continue
	lpm encodedHighDigit,Z+;
	lpm encodedHighDigit,Z;
	dec r22;
	cpi r22,0;
	brne encodeHigherNibbleLoop
	call resetZPointer
	ret

isZeroLow:
	lpm encodedLowDigit,Z;
	rjmp encodeHigherNibble
isZeroHigh:
	lpm encodedHighDigit,Z;
	ret



