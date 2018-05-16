; TIMEPILOT
; drawing Player

.proc drawPlayer

	lda playerFrameDraw		; 0 = we dont need to redraw player 
	bne @+
	rts
@	ldx player.currentFrame
	dec playerFrameDraw ; 1-> 0

	;X - frame animation number 0..15

	;layout offset bits meaning
	;9876543210
	;bbbbssffff
	; b - byte number
	; s - sprite number
	; f - frame number

	.macro node solo
	lda dataSpritePlayer+$000+(:1<<6),x
	and playerMask+:1
	sta bufPM0+63-8+:1
	lda dataSpritePlayer+$010+(:1<<6),x
	and playerMask+:1
	sta bufPM1+63-8+:1
	lda dataSpritePlayer+$020+(:1<<6),x
	and playerMask+16+:1
	sta bufPM2+63-8+:1
	lda dataSpritePlayer+$030+(:1<<6),x
	and playerMask+16+:1
	sta bufPM3+63-8+:1
	.endm

	.rept 16
	node .R
	.endr
	
	rts
	.endp
	
.proc 	hidePlayer
		lda #0
		sta hposp0
		sta hposp1
		sta hposp2
		sta hposp3
		rts
.endp		

.proc 	hideMissiles
		lda #0
		sta hposm0
		sta hposm1
		sta hposm2
		sta hposm3
		rts
.endp	

.proc 	showPlayer
		lda #120
		sta hposp0
		lda #120
		sta hposp1
		lda #128
		sta hposp2
		lda #128
		sta hposp3
		lda #1
		sta playerFrameDraw
		rts
.endp	

