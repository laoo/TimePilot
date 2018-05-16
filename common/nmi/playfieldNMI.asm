; PLAYFIELD NMI

.proc DLIDispatch
	
	nop
	nop
	nop
	
	pha
	lda counterDLI
	lda counterDLI				; its not fuckup;) it must be here - purpose of 3 cycles "nop"
	clc
mode	
	adc #<bufDLIJumps			; or adc #5 for DLI level start (uses bufDLIJumpsLevelStart table) | code modification changes the #value
	sta j+1
	inc counterDLI  			; 2 -> 5 3
	inc counterDLI
j	jmp (bufDLIJumps)
.endp

.proc DLI0
	lda prTabs.visibleFontsH+0
	sta chbase

; code modifications changes the #values of c0-c4
c0	lda #0
	sta colpf0
c1	lda #0
	sta colpf1
c2	lda #0
	sta colpf2
c3	lda #0
	sta colpf3
c4	lda #$84
	sta colbak
	lda #%101110
	sta dmactl
	lda #3
	sta pmactive
	
	pla
	rti
.endp

.proc DLI1
	lda prTabs.visibleFontsH+1
	sta chbase
	pla
	rti
.endp

.proc DLI2
	lda prTabs.visibleFontsH+2
	sta chbase
	pla
	rti
.endp

.proc DLI3
	lda prTabs.visibleFontsH+3
	sta chbase
	pla
	rti
.endp

.proc DLI4
; code modifications changes the #values of c0-c2
	lda #0
	sta colbak
	lda #>dataLogoFonts
	sta chbase
c0	lda #0
	sta colpf0
c1	lda #0
	sta colpf1
c2	lda #0
	sta colpf2
	lda #0
	sta pmactive
	lda #%100010
	sta dmactl
	inc frameCounter
	pla
	rti
.end

; -------------------
; DLI for level start
; -------------------
.proc DLI1b
	lda prTabs.visibleFontsH+1
	sta chbase
	jsr initPlayfieldPMColors	
	jsr showPlayer
	sta wsync
	pla
	rti
.endp

.proc DLI3b
	lda prTabs.visibleFontsH+3
	sta chbase
	lda #textPosX
	sta hposp0
	lda #textPosX+12
	sta hposp1
	lda #textPosX+12*2
	sta hposp2
	lda #textPosX+12*3
	sta hposp3

	; level name color change
	txa
	pha
	ldx levelNameColorCounter
	lda levelNameColor,x
	sta colpm0
	sta colpm1
	sta colpm2
	sta colpm3
	
	sta wsync
	pla
	tax
	pla
	rti
textPosX	equ 106
.endp

.proc DLI4b
	lda #0
	sta colbak
	lda #>dataLogoFonts
	sta chbase
	
; code modifications changes the #values of c0-c2
c0	lda #0
	sta colpf0
c1	lda #0
	sta colpf1
c2	lda #0
	sta colpf2
	lda #0
	sta pmactive
	lda #%100010
	sta dmactl
	inc frameCounter
	
	; level name
	lda playerGameOver
	bne gameOver
	lda #textPosX
	sta hposp0
	lda #textPosX+8
	sta hposp1
	lda #textPosX+8*2
	sta hposp2
	lda #textPosX+8*3
	sta hposp3
	bne colorBlink
	
	; game over
gameOver
	lda #textPosX2
	sta hposp0
	lda #textPosX2+12
	sta hposp1
	lda #textPosX2+12*2
	sta hposp2
	lda #textPosX2+12*3
	sta hposp3
	
colorBlink
	; level name color change + delay	
	txa
	pha
	dec levelNameColorDelay	
	bne @+
	lda #configLevelStartNameBlink
	sta levelNameColorDelay
	dec levelNameColorCounter
	lda levelNameColorCounter
	bpl @+
	lda #3
	sta levelNameColorCounter
	ldx levelNameColorCounter
	lda levelNameColor,x
	sta colpm0
	sta colpm1
@	
	pla
	tax
	pla
	rti
textPosX	equ 116
textPosX2	equ 106
.end

; ------------------
; DLI for Game Over
; ------------------
.proc DLI1c
	lda prTabs.visibleFontsH+1
	sta chbase
	jsr initPlayfieldPMColors	
	jsr hidePlayer
	sta wsync
	pla
	rti
.endp

levelNameColorDelay		dta b(configLevelStartNameBlink)
levelNameColorCounter	dta b(3)
levelNameColor			dta b($72),b($f),b($36),b($f)

; --------------
; playfield VBL
; --------------
.proc playfieldVBL
	pha
	txa
	pha
	tya
	pha
	
	lda #>dataTextFonts
	sta chbase
	
	lda #0
	sta counterDLI

c0	lda #$f
	sta colpf0
	lda #$34
	sta colpf2

	jsr playfieldJoystickVBL
	jsr playfieldSoundVBL
	
	pla
	tay
	pla
	tax
	pla
	rti
.endp

.proc playfieldTransitionVBL
	pha
	txa
	pha
	tya
	pha
	
	lda #>dataLogoFonts
	sta chbase
	
backgroundColor
	lda #0
	sta colbak
	
	lda #$14 ; shadow
	sta colpf2 
	lda #$ee ; main
	sta colpf1
	lda #$34 ; shadow2
	sta colpf0

	jsr playfieldSoundVBL
	
	pla
	tay
	pla
	tax
	pla
	rti
.endp
		
	icl 'inc/playfieldJoystickVBL.asm'
	icl 'inc/playfieldSoundVBL.asm'
