; Enemy fire procedures


.proc enemyFire

.proc velocity

xMax equ prScreenWidth / 2 / 8
yMax equ prScreenHeight / 2 / 8

;in
;position in virtual dimensions 0-255
xPos equ zeroPageLocal+0	;modified after return
yPos equ zeroPageLocal+1

;out
;Z=1 if no value returned 
;computed velocities 0-255 with high bytes equal 0 or 255 depending on sign
xVel equ zeroPageLocal+2
yVel equ zeroPageLocal+4

	lda xPos
	sec
	sbc #128
	bmi leftSide

	lsr
	lsr
	lsr
	cmp #xMax
	jcs exit0
	sta xPos
	
	lda yPos
	sec
	sbc #128
	bmi rightUpperSide

rightLowerSide
	lsr
	lsr
	lsr
	cmp #yMax
	jcs exit0
	tax
	lda mul10,x
	;c i clear
	adc xPos
	tax
	lda #$ff
	sta xVel+1
	sta yVel+1
	lda #0
	sec
	sbc xVelTab,x
	sta xVel
	lda #0
	sec
	sbc yVelTab,x
	sta yVel
	rts

rightUpperSide
	lda #128
	sec
	sbc yPos
	lsr
	lsr
	lsr
	cmp #yMax
	bcs exit0
	tax
	lda mul10,x
	;c i clear
	adc xPos
	tax
	lda #$ff
	sta xVel+1
	lda #0
	sta yVel+1
	sec
	sbc xVelTab,x
	sta xVel
	lda yVelTab,x
	sta yVel
	rts
	
leftSide
	lda #128
	sec
	sbc xPos
	lsr
	lsr
	lsr
	cmp #xMax
	bcs exit0
	sta xPos
	
	lda yPos
	sec
	sbc #128
	bmi leftUpperSide

leftLowerSide
	lsr
	lsr
	lsr
	cmp #yMax
	bcs exit0
	tax
	lda mul10,x
	;c i clear
	adc xPos
	tax
	lda xVelTab,x
	sta xVel
	lda #$ff
	sta yVel+1
	lda #0
	sta xVel+1
	sec
	sbc yVelTab,x
	sta yVel
	rts

leftUpperSide
	lda #128
	sec
	sbc yPos
	lsr
	lsr
	lsr
	cmp #yMax
	bcc cont

exit0
	lda #0
	rts

cont
	tax
	lda mul10,x
	;c i clear
	adc xPos
	tax
	lda #0
	sta xVel+1
	sta yVel+1
	lda xVelTab,x
	sta xVel
	lda yVelTab,x
	sta yVel
	rts

m equ 800	; velocity multiplier m/1000 (example 800/1000 = 0.8) | max is 1000 (multiplier=1.0)
xVelTab
	dta b(0),b(0),b(0),b(0),b(0),b(0),b(253*m/1000),b(254*m/1000),b(254*m/1000),b(255*m/1000)
	dta b(0),b(0),b(0),b(0),b(0),b(0),b(246*m/1000),b(248*m/1000),b(250*m/1000),b(251*m/1000)
	dta b(0),b(0),b(0),b(0),b(0),b(229*m/1000),b(235*m/1000),b(240*m/1000),b(243*m/1000),b(245*m/1000)
	dta b(0),b(0),b(0),b(181*m/1000),b(200*m/1000),b(213*m/1000),b(222*m/1000),b(229*m/1000),b(234*m/1000),b(238*m/1000)
	dta b(0),b(0),b(132*m/1000),b(160*m/1000),b(181*m/1000),b(197*m/1000),b(208*m/1000),b(217*m/1000),b(224*m/1000),b(229*m/1000)
	dta b(0),b(81*m/1000),b(114*m/1000),b(142*m/1000),b(164*m/1000),b(181*m/1000),b(194*m/1000),b(205*m/1000),b(213*m/1000),b(220*m/1000)

yVelTab
	dta b(0),b(0),b(0),b(0),b(0),b(0),b(36*m/1000),b(32*m/1000),b(28*m/1000),b(25*m/1000)
	dta b(0),b(0),b(0),b(0),b(0),b(0),b(70*m/1000),b(62*m/1000),b(56*m/1000),b(50*m/1000)
	dta b(0),b(0),b(0),b(0),b(0),b(114*m/1000),b(101*m/1000),b(90*m/1000),b(81*m/1000),b(74*m/1000)
	dta b(0),b(0),b(0),b(181*m/1000),b(160*m/1000),b(142*m/1000),b(127*m/1000),b(114*m/1000),b(104*m/1000),b(95*m/1000)
	dta b(0),b(0),b(220*m/1000),b(200*m/1000),b(181*m/1000),b(164*m/1000),b(149*m/1000),b(136*m/1000),b(124*m/1000),b(114*m/1000)
	dta b(0),b(243*m/1000),b(229*m/1000),b(213*m/1000),b(197*m/1000),b(181*m/1000),b(167*m/1000),b(154*m/1000),b(142*m/1000),b(132*m/1000)

mul10
	dta b(0),b(10),b(20),b(30),b(40),b(50)
.endp


.proc hitClear
	sta hitclr
	rts
.endp

;returns which missile hit the player
;return -1 for none
.proc hitTest
	lda kolm0p
	beq @+
m0	lda #0
	rts
@	lda kolm1p
	bne m0
	lda kolm2p
	beq @+
m1	lda #1
	rts
@	lda kolm3p
	bne m1
	lda #$ff
	rts
.endp

;in
;A - 0 or 1 for missle number
;
;out
;A - 0 or 2 for missle number
.proc clear
	asl
	tax
	;x is 0 or 2

	;clear old position
	ldy ycache,x
	lda bufM+0,y
	and clearmask,x
	sta bufM+0,y
	lda bufM+1,y
	and clearmask,x
	sta bufM+1,y
	rts
.endp

.proc draw

;in
;position in virtual dimensions 0-255
;A - 0 or 2 for missle number
;out
;A=-1 if out of bounds
xPos equ zeroPageLocal+0
yPos equ zeroPageLocal+1

temp equ zeroPageLocal+0

	lda xPos
	cmp #prScreenXMin
	bcc exit
	cmp #prScreenXMax
	bcs exit
	lda yPos
	cmp #prScreenYMin
	bcc exit
	cmp #prScreenYMax-2
	bcc @+

exit
	lda #$ff
	rts

@	sec
	sbc #64
	sta ycache,x
	tay

	lda xPos
	sta hposm0,x
	sta hposm1,x
	lda clearmask,x
	sta temp
	eor #$ff
	sta temp+1
	lda state,x
	eor #1
	sta state,x
	tax
	
	lda bufM+0,y
	and temp
	sta temp+2
	lda bufM+1,y
	and temp
	sta temp+3
	
	lda mask,x
	and temp+1
	ora temp+2
	sta bufM+0,y
	lda mask+1,x
	and temp+1
	ora temp+3
	sta bufM+1,y
	lda #0
	rts

.endp

mask
	.by $ff,$ff,$ff							; lvl 1-4
	;.by %1011010,%10100101,%01011010		; lvl 5

;clearmask/clearmask1, ycache/ycache1, clearmask1/clearmask2, state/state1 are ingexed by index 0 or 2
clearmask
	.by %11110000
ycache
	.by 0
clearmask1
	.by %00001111
ycache1
	.by 0
clearmask2
	.by %11110000
state
	.by 0
ignored
	.by 0
state1
	.by 0
.endp
