

.proc	initPlayfield

	lda #configMusicStartGame
	jsr sound.soundInit.changeSong

	jsr clearbufScreen.s1
	jsr waitFrameNormal
	jsr clearbufScreenTxt
	jsr clearBufPM

	jsr waitFrame
	jsr clearBufFontsHidden
	jsr playfieldTransition

	ldx gameCurrentLevel
	jsr level.init
	
	jsr waitFrameNormal
	jsr initPlayfieldPM
	jsr initPlayfieldPMColors
	jsr enemyFire.hitClear
	jsr copyPlayfieldTexts
	lda #0
	sta bufScreenNr 
	jsr clearbufScreenSimple	
	jsr setPlayfieldNMI
	jsr waitFrameNormal
	jmp initPlayfieldDlist
	
.endp


initPlayfieldDlist
	lda <dataPlayfieldDlist
	sta dlptr
	lda >dataPlayfieldDlist
	sta dlptr+1
	rts

				
initPlayfieldPM			; PM on/off on DLI, not here
	lda #>bufPMBase
	sta pmbase
	
	lda #0
	sta sizep0
	sta sizep1
	sta sizep2
	sta sizep3
	sta sizem
	
	jsr showPlayer
	
	lda #%100001
	sta gtiactl
	rts
	
initPlayfieldPMColors
	lda #$58
	sta colpm0
	sta colpm2
	lda #$77
	sta colpm1
	sta colpm3
	rts

initPlayfieldPMColorsWhite
	lda #$f
	sta colpm0
	sta colpm2
	sta colpm1
	sta colpm3
	rts
	
.proc setPlayfieldNMI
	lda #0
	sta nmien       
	lda #<DLIDispatch
	sta NMI.DLI+1
	lda #>DLIDispatch
	sta NMI.DLI+2
	
	lda #<playfieldVBL
	sta NMI.VBL+1
	lda #>playfieldVBL
	sta NMI.VBL+2
	
	lda #$c0    
	sta nmien 
	rts
.endp

.proc	copyPlayfieldTexts
	; 1-UP
	lda #%10000000
	ldx #<playfieldTexts.player
	ldy #>playfieldTexts.player
	jsr copyText
	
	; score
	lda #0
	ldx #<playfieldTexts.score
	ldy #>playfieldTexts.score
	jsr copyText
	
	; HI
	lda #%10000000
	ldx #<playfieldTexts.high
	ldy #>playfieldTexts.high
	jsr copyText
	
	; score
	lda #0
	ldx #<playfieldTexts.score2
	ldy #>playfieldTexts.score2
	jmp copyText
	
.endp

.proc playfieldTransition
	jsr setPlayfieldTransitionNMI
	jsr waitFrameNormal
	lda <dataPlayfieldDlist2
	sta dlptr
	lda >dataPlayfieldDlist2
	sta dlptr+1
	
start
	
color
	lda #$80
	sta colpf3
	
	lda #20		; x2 20-39
	sta pos
	
t1	lda #20
	sta drawTo.x1
	lda #6 
	sta drawTo.y1
	lda #0
	sta drawTo.y2
	lda pos
	sta drawTo.x2
	jsr drawTo.draw
	jsr waitFrameNormal
	inc pos
	lda pos
	cmp #40
	bne t1
	
	lda #1		; y2 0-39
	sta pos
t2	lda #20
	sta drawTo.x1
	lda #6 
	sta drawTo.y1
	lda pos
	sta drawTo.y2
	lda #39
	sta drawTo.x2
	jsr drawTo.draw
	ldx #2
	jsr waitXFrames
	inc pos
	lda pos
	cmp #13
	bne t2

	lda #39
	sta pos
t3	lda #20
	sta drawTo.x1
	lda #6 
	sta drawTo.y1
	lda pos
	sta drawTo.x2
	lda #12
	sta drawTo.y2
	jsr drawTo.draw
	jsr waitFrameNormal
	dec pos
	lda pos
	cmp #$ff
	bne t3

	lda #12
	sta pos
t4	lda #20
	sta drawTo.x1
	lda #6 
	sta drawTo.y1
	lda #0
	sta drawTo.x2
	lda pos
	sta drawTo.y2
	jsr drawTo.draw
	ldx #2
	jsr waitXFrames
	dec pos
	lda pos
	bne t4

	lda #0		; x2 20-39
	sta pos
t5	lda #20
	sta drawTo.x1
	lda #6 
	sta drawTo.y1
	lda #0
	sta drawTo.y2
	lda pos
	sta drawTo.x2
	jsr drawTo.draw
	jsr waitFrameNormal
	inc pos
	lda pos
	cmp #20
	bne t5		
	rts

pos	dta b(0)
.endp	

.proc setPlayfieldTransitionNMI
	lda #0
	sta nmien       
	lda #<playfieldTransitionVBL
	sta NMI.VBL+1
	lda #>playfieldTransitionVBL
	sta NMI.VBL+2
	lda #$c0    
	sta nmien 
	rts
.endp

.local playfieldTexts
player		dta b(10),b(0),d'1UP#'
score		dta b(18),b(0),d'00#'
high		dta b(0),b(0),d'HI#'
score2		dta b(2),b(0),d'  10000#'
.endl



	
