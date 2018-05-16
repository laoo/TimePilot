; TITLE SCREEN NMI
.proc	titleScreenDLI
    sta wsync
	pha
	inc counterDLI
	lda counterDLI
	cmp #1
	beq dl1
	cmp #2
	beq dl2
	cmp #3
	beq dl3
	pla
	rti
	
dl1	
	lda #$14 		
	sta colpf2 
	lda #$ee 		
	sta colpf1
	lda #$34 		
	sta colpf0
	lda #>dataLogoFonts
	sta chbase
	pla
	rti

dl2	
	lda color
	sta colpf0 
	lda #>dataTextFonts
	sta chbase
	pla
	rti
	
dl3	
	lda color+1
	sta colpf0 
	pla
	rti

color		dta b($80),(0)
colorDelay	dta b(2)
colorTarget	dta b($88),b($f)
	
.endp

.proc	titleScreenHiScoreDLI
    sta wsync
	pha
	txa
	pha
	
	inc counterDLI
	lda counterDLI
	cmp #1
	bne fadeInOut
	; title logo
	lda #$14 		
	sta colpf2 
	lda #$ee 		
	sta colpf1
	lda #$34 		
	sta colpf0
	lda #>dataLogoFonts
	sta chbase
	
	pla
	tax
	pla
	rti
	
fadeInOut
	lda #>dataTextFonts		; redundant every dli line but saves few bytes
	sta chbase
	
rankingMode		

	lda titleScreen.screenMode
	cmp #2
	beq fadeIn
	cmp #3
	beq fadeOut
	pla
	tax
	pla
	rti
	 
fadeIn				; we do it here so we have easy fadeIn swift per line  
	ldx counterDLI
	dex
	dex
	lda rankingColors,x
	cmp rankingColorsTarget,x
	beq r1
	dec rankingColorsDelay
	bne r1
	lda #4
	sta rankingColorsDelay
	inc rankingColors,x
	lda rankingColors,x
r1	sta colpf0 
	pla
	tax
	pla
	rti

fadeOut
	ldx counterDLI
	dex
	dex
	lda rankingColors,x
	and #$f
	beq r2
	dec rankingColorsDelay
	bne r2
	lda #4
	sta rankingColorsDelay
	dec rankingColors,x
	lda rankingColors,x
r2	sta colpf0 
	pla
	tax
	pla
	rti
	
rankingColorsDelay	dta b(4)
rankingColorsMode	dta b(0)
rankingColors			dta b($50),b($30),b($f0),b($d0),b($c0),b($90)	
rankingColorsTarget 	dta b($58),b($34),b($fa),b($de),b($c8),b($98)
	
.endp


;---------------------
; TITLE SCREEN VBLANK
;---------------------
.proc	titleScreenVBL
	pha
	txa
	pha
	tya
	pha
	
	lda SCORE.doHighScoreFlag
	beq @+
	jsr playfieldSoundVBL
@
	lda #0
	sta counterDLI 
	sta colbak
	lda #$88
	sta colpf0 
	lda #>dataTextFonts
	sta chbase
	

	lda titleScreen.screenMode
	cmp #0
	beq fadeIn
	cmp #1
	beq fadeOut
	jmp skip

fadeIn	
	dec titleScreenDLI.colorDelay
	bne skip
	lda #2
	sta titleScreenDLI.colorDelay
	lda titleScreenDLI.color
	cmp titleScreenDLI.colorTarget
	beq v1
	inc titleScreenDLI.color
v1	lda titleScreenDLI.color+1
	cmp titleScreenDLI.colorTarget+1
	beq skip
	inc titleScreenDLI.color+1
	jmp skip
fadeOut
	lda titleScreenDLI.color
	and #$f
	beq v2
	dec titleScreenDLI.color
v2	lda titleScreenDLI.color+1
	and #$f
	beq skip
	dec titleScreenDLI.color+1
skip	
	pla
	tay
	pla
	tax
	pla
	rti
.endp

