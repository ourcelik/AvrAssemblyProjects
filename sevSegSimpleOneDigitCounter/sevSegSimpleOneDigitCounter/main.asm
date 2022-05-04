;
; sevSegSimpleOneDigitCounter.asm
;
; Created: 4/25/2022 5:18:08 PM
; Author : ource
;


; Replace with your application code
.include"m328PBdef.inc"
	rjmp start
.org 0x32 ;Reserve data space at 0x32 address (16-bit addressing)
prime: .DB 0x7E, 0x30,0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B,0x77,0x1F,0x4E,0x3D,0x4F,0x47 ;Create array of the first ten primes in code memory
.org 0x100
start:
	ldi r21,16;

	ldi zl, low(2*prime) ;multiply by 2 to use byte by byte addressing
	ldi zh, high(2*prime)

	ldi r16, 0xff
	out ddrd, r16 ;Set Port A as output
	out ddrc, r16 ;Set Port B as output
	ldi r16, 0x01 ; Select first digit
	com r16 ;Digit is zero active
	out portc, r16 ; Set port B
	call increaseVal
	rjmp start

	
stop: rjmp stop

wait:
	ldi r18,50
	ldi r19,5
	ldi r20,1
outerloop:
innerloop:
innerinnerloop:
	dec r20
	brne innerinnerloop
	dec r19		; decrement loop count
	brne innerloop
	dec r18
	brne outerloop
	ret

increaseVal:
	
	call wait
	dec r21
	lpm r16, z+
	com r16 ; Display is common-anode, so segments are activated by '0'
	out portd, r16 ; Set port A
	cpi	r21,0; check if r16 is zero
	brne increaseVal
	ret


	
	
	
		
