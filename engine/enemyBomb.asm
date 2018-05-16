; Enemy fire procedures


.proc enemyBomb
;Y - bomb index (object at OL.tab list)
;A - positive bomb flies rightwards
;A - negative bomb flies leftwards
.proc init
	pha
	lda #$ff
	sta ol.tab.velYH+olCommon,y
	lda #0
	sta ol.tab.velYL+olCommon,y
	sta ol.tab.velXL+olCommon,y
	lda rapidusDetected
	bne rapidus
	pla
	bmi negative
positive
	lda #$ff
	sta ol.tab.velXH+olCommon,y
	rts
negative
	lda #1
	sta ol.tab.velXH+olCommon,y
	rts

rapidus	
	lda #$80
	sta ol.tab.velXL+olCommon,y
	pla
	bpl positive
	lda #$0
	sta ol.tab.velXH+olCommon,y
	rts
.endp

;X - bomb index (object at OL.tab list) | included offset to olCommon objects
.proc process
tmp	equ zeroPageLocal
	
	lda gameCurrentLevel
	cmp #5
	bcc lvl1_4
					
	lda ol.tab.enemyBombDirection,x			; ufo missile acc lvl 5
	bne @+
	
	clc										; ufo missile down
	lda ol.tab.velYL,x
	lda random
auto0 equ *+1
	and #31
	adc ol.tab.velYL,x
	sta ol.tab.velYL,x
	lda ol.tab.velYH,x
	adc #0
	sta ol.tab.velYH,x
	rts
@ 	
	sec										; ufo missile up
	lda random
auto1 equ *+1
	and #15
	sta tmp
	lda ol.tab.velYL,x
	sbc tmp
	sta ol.tab.velYL,x
	lda ol.tab.velYH,x
	sbc #0
	sta ol.tab.velYH,x
	rts

lvl1_4										; bomb acc lvl 1-4	
	;clc !
	lda ol.tab.velYL,x
auto2 equ *+1
	adc #32
	sta ol.tab.velYL,x
	bcc @+
	inc ol.tab.velYH,x
@	rts
	
.endp



.endp
