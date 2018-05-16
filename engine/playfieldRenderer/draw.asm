

//drawing small bullet. 1 pixel
//x - index in object list table
.proc	prDrawPlayerFire
	
prXOff		equ prTemp+5
prRowRem	equ bufRLIDof
prColRem	equ prTemp+7
prFontNr	equ prTemp+8 	;font number
prScreenOff	equ prTemp+9 	;w	offset in screen buffer
prFntOff	equ	bufRLIDsL	;offset in font

	lda ol.tab.posXH,x
	lsr
	lsr
	tay
	lda prTabs.xoff,y
	bpl cont 
	
outOfBounds
	lda #$ff
	rts
 	
cont
	sta prXOff
	lda ol.tab.posYH,x
	lsr
	lsr
	lsr
	tay
	lda prTabs.fontNr,y
	bmi outOfBounds

	sta prFontNr
	lda ol.tab.posYH,x
	and #$7
	sta prRowRem
	lda ol.tab.posXH,x
	and #3
	sta prColRem
	
	lda prTabs.scrLo,y
	clc
	adc prXOff
	sta prScreenOff
	lda prTabs.scrHi,y
	adc #0
	sta prScreenOff+1
	
	ldx prFontNr
	ldy #0
	lda (prScreenOff),y
	bne mergeFire

	;allocating font
	lda fntAlloc,x
	sta prFntOff
	ora #$80
	sta (prScreenOff),y
	inc fntAlloc,x
	lda #0
	asl prFntOff
	asl prFntOff
	rol
	asl prFntOff
	rol
	adc prTabs.fontsH,x
	sta bufRLIDsH
;	lda prFntOff
;	sta bufRLIDsL
	ldy prColRem
	ldx bitmap,y
;	stx bufRLIVal
;	lda prRowRem
;	sta bufRLIDof
	rliCmdDrawPixel
	lda #0
	rts

	;font already present
mergeFire
	sta prFntOff
	lda #0
	asl prFntOff
	asl prFntOff
	rol
	asl prFntOff
	rol
	adc prTabs.fontsH,x
	sta bufRLIDsH
;	lda prFntOff
;	sta bufRLIDsL
	ldy prColRem
	lda bitmap,x
	;sta bufRLIVal
	ldy prRowRem
	rliCmdMergePixel
	lda #0
	rts

bitmap
		dta b(%11000000)
		dta b(%00110000)
		dta b(%00001100)
		dta b(%00000011)
.endp


; X - object number in ol.tab
.proc	prDrawEnemy
tmpFrame	equ zeroPageLocal
	
	lda ol.tab.frame,x
	sta tmpFrame
	; custom animations for level 3 and 5
	lda gameCurrentLevel
	cmp #5
	beq lvl5
	cmp #3
	bne draw
	ldy tmpFrame
	lda level3,y
	sta tmpFrame
	bpl	draw
lvl5
	lda animationSwitch			; 0-1 frames for lvl5 enemies in loop
	sta tmpFrame	
draw
	clc	
	lda prObjId
	adc tmpFrame
	
	tay
	lda ebGfxScrsL,y
	sta prGfxScr
	lda ebGfxScrsH,y
	sta prGfxScr+1

	bne prDrawGeneric ;!

; level 3 has different animation frames per movement frame
level3 dta b(4),b(3),b(2),b(1),b(0),b(1),b(2),b(3),b(4),b(5),b(6),b(7),b(8),b(7),b(6),b(5)
.endp

; X - object number in ol.tab
.proc	prDrawObject
	clc
	lda ol.tab.frame,x
	adc prObjId
	tay
	lda ebGfxScrsL,y
	sta prGfxScr
	lda ebGfxScrsH,y
	sta prGfxScr+1
; fall through
;	jmp prDrawGeneric		; it will execute prDrawGeneric
.endp

; x - index in object list table
; returns 0 on successful draw
; returns $ff if object is out of bounds
; returns 1 if object with colission with player
 
.proc	prDrawGeneric

prRow		equ prTemp+4
prColRem	equ prTemp+5
prRowRem	equ prTemp+6
prWidth1	equ prTemp+7	;iterations left in one x loop
prXOff		equ prTemp+8	;x screen offset (bytes)
prWidth		equ prTemp+9
prYIter		equ prTemp+10	;y iteration in pixels i.e. offset in source graphics
prYOff		equ prTemp+11	;y screen offset (font rows)
prScreenOff	equ prTemp+12 	;w	offset in screen buffer
prFntOff	equ prTemp+14	;offset in font
prSrcGfx	equ prTemp+15	;w
prBottomN	equ prTemp+17	;N if set if ther are more than 8 Y iterations left
prBottomCnt	equ prTemp+18	;number of iterations to bottom
prNewFont	equ prTemp+19	;zero if new fot has been allocated
prSrcGfx1	equ bufRLISrL	;w
prCurHeight equ prTemp+22	;current height 
prExit		equ prTemp+23	;exit status
prPlayer	equ prTemp+24	;w player mask

	lda ol.tab.posXH,x
	lsr
	lsr
	tay
	lda prTabs.xoff,y
	bpl xpos
	asl
	bpl xneg	
	
outOfBounds
	lda #$ff
	rts

xneg
	lsr
	sta prWidth1		;on 4 bits of prTabs.xoff is encoded how many iterations are out of screen
	cmp prObjWidth
	bcc @+
	clc
	bne outOfBounds
	lda ol.tab.posXH,x
	and #3
	beq outOfBounds
	bne xneg2
@	lda ol.tab.posXH,x
	and #3
xneg2	sta prColRem
	lda prGfxScr+1
	sta prSrcGfx+1
  lda prGfxScr
	ldy prWidth1
	beq xneg1 
xneg0
	adc prGfxNextOff+4
	bcc @+
	inc prSrcGfx+1
	clc
@	dey
	bne xneg0

xneg1
	ldy prColRem
	adc prGfxNextOff,y
	sta prSrcGfx
	lda #0
	sta prXOff
	adc prSrcGfx+1
	sta prSrcGfx+1
	bne xcont
	
xpos
	sta prXOff
	lda ol.tab.posXH,x
	and #3
	sta prColRem
	tay
	lda #0
	sta prWidth1
	lda prGfxScr
	clc
	adc prGfxNextOff,y  
	sta prSrcGfx
	lda prGfxScr+1
	adc #0
	sta prSrcGfx+1

xcont

?temp = prNewFont

	lda #40
	sec
	sbc prXOff
	sta ?temp
	lda prObjWidth
	sec
	sbc prWidth1
	sta prWidth
	lda prColRem
	beq @+
	inc prWidth	;with is one itration greater if we don't start from beginning of font
@
	lda prWidth
	cmp ?temp
	bcc @+
 	lda ?temp
 	sta prWidth
@	lda ol.tab.posYH,x
	and #$7
	sta prRowRem
	lda #prScreenYMax
	sec
	sbc ol.tab.posYH,x
	sec
	sbc prObjHeight
	bcs fullHeight
	adc prObjHeight
	sta prCurHeight
	jmp @+ 
fullHeight
	lda prObjHeight
	sta prCurHeight
@	lda ol.tab.posYH,x
	lsr
	lsr
	lsr
	tay
	lda prTabs.fontNr,y
	bpl ypos
	
	asl
	jmi outOfBounds	;if 6th bit is set - we're below the screen
	sbc prRowRem	;on lower bits there are encoded number of iteration out of screen
	sta prYIter
	clc
	adc prSrcGfx
	sta prSrcGfx
	bne @+
	inc prSrcGfx+1
@
	lda #10
	sta prYOff
	lda #0
	sta prRowRem
	beq yloopStart	;!

exit
	lda prExit
	rts

ypos
	sty prYOff
	lda #0
	sta prYIter

yloopStart
	lda #0
	sta prExit	
yloop
	lda prCurHeight
	sec
	sbc prYIter
	beq exit
	bcc exit

	sta prBottomCnt
	cmp #8
	ror prBottomN	;setting N bit if there are more than 8 iterations left

	lda prSrcGfx
	sec
	sbc prRowRem
	sta prSrcGfx1
	lda prSrcGfx+1
	sbc #0
	sta prSrcGfx1+1

	ldy prYOff
	lda prTabs.scrLo,y
	clc
	adc prXOff
	sta prScreenOff
	lda prTabs.scrHi,y
	adc #0
	sta prScreenOff+1
	lda prWidth
	sta prWidth1
	
xloopJmp equ *+1
	jmp * ; automidification in prepare phase
	
nextyLoop

?temp = prNewFont

	inc prYOff
	lda #8
	ldy prRowRem
	beq nextyLoop1
	sec
	sbc prRowRem
	sta ?temp
	clc
	adc prYIter
	sta prYIter
	lda #0
	sta prRowRem
	lda prSrcGfx
	clc
	adc ?temp
	sta prSrcGfx
	bne yloop
	inc prSrcGfx+1
@	bne yloop ;!
nextyLoop1
	clc
	adc prYIter
	sta prYIter
	lda prSrcGfx
	clc
	adc #8
	sta prSrcGfx
	bne yloop
	inc prSrcGfx+1
@	bne yloop ;!


.proc StandardXLoop
	lda prTabs.fontNr,y
	adc #<fntAlloc
	sta fntAllocA0
	sta fntAllocA1
	;c is clear
	sbc #<fntAlloc-1
	;c is set
	tay
	lda prTabs.fontsH,y
	sta fontsHA

xloop
	ldy #0
	lda (prScreenOff),y
	sta prNewFont
	beq clearFont
	sta bufRLIDsL		;font low
	cmp #fontsReservedForPlayerLocation
	bcc dirtyFont
	lda prExit
exitResult equ *+1
	ora #0
	sta prExit
	jmp dirtyFont 
	
clearFont
	;allocating font
fntAllocA0 equ *+1
	lda fntAlloc
	sta bufRLIDsL		;font low
highFontDeterminant equ *+1
	ora #$80
	sta (prScreenOff),y
fntAllocA1 equ *+1
	inc fntAlloc
	
dirtyFont
	tya
	asl bufRLIDsL
	asl bufRLIDsL
	rol
	asl bufRLIDsL
	rol
fontsHA equ *+1
	adc #0
	sta bufRLIDsH		;destination font high
;	lda prSrcGfx1
;	sta bufRLISrL		;source low
;	lda prSrcGfx1+1
;	sta bufRLISrH		;source high
	;now we decide which command to use
	lda prNewFont
	bne csMerge
csDraw	;new font is drawn
	ldy prRowRem
	beq csDrawFullOrTop
csDrawBot	;drawing bottom part of the font
;	sta bufRLIDof
	jsr rliCmdDrawBot
	jmp nextxLoop


csDrawFullOrTop
	bit prBottomN
	bmi csDrawFull

csDrawTop	;drawing top part of the font
	lda prBottomCnt
	sta bufRLILen
	jsr rliCmdDrawTop
	jmp nextxLoop
	
csDrawFull	;drawing full font
	jsr rliCmdDrawFull

nextxLoop
	dec prWidth1
	jeq nextyLoop

	inc prScreenOff
	bne @+
	inc prScreenOff+1
@	lda prSrcGfx1
	clc
	adc prGfxNextOff+4
	sta prSrcGfx1
	bcc xloop
	inc prSrcGfx1+1
 	bne xloop	;!

csMerge	;merging to existing font
	lda prGfxMaskOff
	sta bufRLIMsk		;mask offset

	ldy prRowRem
	beq csMergeFullOrTop
csMergeBot	;merging bottom part of the font
;	sta bufRLIDof
	jsr rliCmdMergeBot
	jmp nextxLoop

csMergeFullOrTop
	bit prBottomN
	bmi csMergeFull

csMergeTop	;drawing top part of the font
	lda prBottomCnt
	sta bufRLILen
	jsr rliCmdMergeTop
	jmp nextxLoop
	
csMergeFull	;drawing full font
	jsr rliCmdMergeFull
	jmp nextxLoop
	
.endp

.proc Cloud3XLoop
	lda prTabs.fontNr,y
	adc #<fntAlloc
	sta fntAllocA0
	sta fntAllocA1
	;c is clear
	sbc #<fntAlloc-1
	;c is set
	tay
	lda prTabs.fontsH,y
	sta prFntOff

xloop
	ldy #0
	lda (prScreenOff),y
	bne dirtyFont
	
	;allocating font
fntAllocA0 equ *+1
	lda fntAlloc
	sta bufRLIDsL		;destination low
	ora #$80
	sta (prScreenOff),y
fntAllocA1 equ *+1
	inc fntAlloc
		
	tya
	asl bufRLIDsL
	asl bufRLIDsL
	rol
	asl bufRLIDsL
	rol
	adc prFntOff
	sta bufRLIDsH		;destination high
;	lda prSrcGfx1
;	sta bufRLISrL		;source low
;	lda prSrcGfx1+1
;	sta bufRLISrH		;source high

csDraw	;new font is drawn
	ldy prRowRem
	beq csDrawFullOrTop
csDrawBot	;drawing bottom part of the font
;	sta bufRLIDof
	jsr rliCmdDrawBot
	jmp nextxLoop

csDrawFullOrTop
	bit prBottomN
	bmi csDrawFull

csDrawTop	;drawing top part of the font
	lda prBottomCnt
	sta bufRLILen
	jsr rliCmdDrawTop
	jmp nextxLoop
	
csDrawFull	;drawing full font
	jsr rliCmdDrawFull

nextxLoop
	dec prWidth1
	jeq nextyLoop

	inc prScreenOff
	bne @+
	inc prScreenOff+1
@	lda prSrcGfx1
	clc
	adc prGfxNextOff+4
	sta prSrcGfx1
	bcc xloop
	inc prSrcGfx1+1
@	bne xloop ;!	

dirtyFont
	cmp #fontsReservedForPlayerLocation
	bcc notOnPlayer 
	
	sta bufRLIDsL		;source font low
	sta playerMaskTouched
	
	tax
	lda prTabs.playerMaskByFontL-fontsReservedForPlayerLocation,x
	sta prPlayer
	lda prTabs.playerMaskByFontH-fontsReservedForPlayerLocation,x
	sta prPlayer+1
	tya
	asl bufRLIDsL
	asl bufRLIDsL
	rol
	asl bufRLIDsL
	rol
	adc prFntOff
	sta bufRLIDsH		;destination high
;	lda prSrcGfx1
;	sta bufRLISrL		;source low
;	lda prSrcGfx1+1
;	sta bufRLISrH		;source high

csMerge2	;merging to existing font
	lda prGfxMaskOff
	sta bufRLIMsk		;mask offset

	ldy prRowRem
	beq csMergeFullOrTop2
csMergeBot2	;merging bottom part of the font
	jsr rliCmdMergeBot
	ldy prRowRem
	jsr rliCmdMaskBot
	jmp nextxLoop

csMergeFullOrTop2
	bit prBottomN
	bmi csMergeFull2

csMergeTop2	;drawing top part of the font
	lda prBottomCnt
	sta bufRLILen
	jsr rliCmdMergeTop
	jsr rliCmdMaskTop
	jmp nextxLoop
	
csMergeFull2	;drawing full font
	jsr rliCmdMergeFull
	rliCmdMaskFull
	jmp nextxLoop
		
notOnPlayer
	bmi highFont
	ora #$80
	sta (prScreenOff),y

highFont
	sta bufRLIDsL		;source font low
		
	tya
	asl bufRLIDsL
	asl bufRLIDsL
	rol
	asl bufRLIDsL
	rol
	adc prFntOff
	sta bufRLIDsH		;destination high
;	lda prSrcGfx1
;	sta bufRLISrL		;source low
;	lda prSrcGfx1+1
;	sta bufRLISrH		;source high

csMerge	;merging to existing font
	lda prGfxMaskOff
	sta bufRLIMsk		;mask offset

	ldy prRowRem
	beq csMergeFullOrTop
csMergeBot	;merging bottom part of the font
;	sta bufRLIDof
;	tay
	jsr rliCmdMergeBot
	jmp nextxLoop

csMergeFullOrTop
	bit prBottomN
	bmi csMergeFull

csMergeTop	;drawing top part of the font
	lda prBottomCnt
	sta bufRLILen
	jsr rliCmdMergeTop
	jmp nextxLoop
	
csMergeFull	;drawing full font
	jsr rliCmdMergeFull
	jmp nextxLoop
.endp
.endp

.local prTabs

fontNr	.he a8 a4 a0 9c 98 94 90 8c 88 84 00 00 00 01 01 01 02 02 02 03 03 03 ff ff ff ff ff ff ff ff ff ff
scrLo	.he ff ff ff ff ff ff ff ff ff ff 00 28 50 78 a0 c8 f0 18 40 68 90 b8 ff ff ff ff ff ff ff ff ff ff
scrHi	.he ff ff ff ff ff ff ff ff ff ff 00 00 00 00 00 00 00 01 01 01 01 01 ff ff ff ff ff ff ff ff ff ff
xoff	.he 8c 8b 8a 89 88 87 86 85 84 83 82 81 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27 ff ff ff ff ff ff ff ff ff ff ff ff
fontsH	dta h(bufFonts0a),h(bufFonts1a),h(bufFonts2a),h(bufFonts3a)
visibleFontsH	dta h(bufFonts0b),h(bufFonts1b),h(bufFonts2b),h(bufFonts3b)
playerMaskByFontL dta l(playerMask),l(playerMask),l(playerMask+16),l(playerMask+16),l(playerMask+8),l(playerMask+8),l(playerMask+24),l(playerMask+24)
playerMaskByFontH dta h(playerMask),h(playerMask),h(playerMask+16),h(playerMask+16),h(playerMask+8),h(playerMask+8),h(playerMask+24),h(playerMask+24)
playerMaskTable .he 0f f0
.endl
