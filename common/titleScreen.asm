

.proc	titleScreen
	
	jsr waitFrameNormal
	lda #0
	sta dmactl
	
	jsr clearbufScreenSimple
	jsr clearbufScreenTxt
	jsr copyTitleLogo
	jsr copyTitleTexts
	jsr waitFrameNormal
	
	lda <dataTitleScreenDlist
	sta dlptr
	lda >dataTitleScreenDlist
	sta dlptr+1
	jsr setTitleScreenNMI
	
	jsr gameInit.disablePM
	jsr RMT.rmt_silence
		
	lda SCORE.doHighScoreFlag
	beq titleLoop	
	lda ntsc
	sta ntsc_counter
	jmp SCORE.doHighScore
	
titleLoop
	
	jsr waitFrameNormal
	dec screenDelay
	bne skip
	inc screenMode
	lda screenMode
	cmp #1
	beq mode1
	cmp #2
	beq mode2
	cmp #3
	beq mode3
	
mode0
	jsr titleScreenMode0
	jmp skip
mode1	
	jsr titleScreenMode1
	bne skip
mode2	
	jsr titleScreenMode2
	jmp skip

mode3
	jsr titleScreenMode3

skip
	lda trig0
	beq normalMode
	lda consol
	cmp #6
	beq normalMode
	cmp #5
	bne titleLoop
	lda rapidusDetected
	beq titleLoop
	jmp gameModes.swarm

normalMode
	jmp gameModes.normal
	
screenDelay	dta b(200)
screenMode	dta b(0)
.endp

.proc titleScreenMode0
	lda #200
	sta	titleScreen.screenDelay 
	lda #0
	sta titleScreen.screenMode
	sta titleScreenDLI.color+1
	lda #$80
	sta titleScreenDLI.color
	jsr waitFrameNormal
	jsr setTitleScreenNMI
	jsr waitFrameNormal
	lda <dataTitleScreenDlist
	sta dlptr
	lda >dataTitleScreenDlist
	sta dlptr+1
	jmp copyTitleTexts
	
.endp

.proc titleScreenMode1
	lda #10
	sta	titleScreen.screenDelay
	rts 	
.endp

.proc titleScreenMode2
	lda #200
	sta	titleScreen.screenDelay 
	jsr waitFrameNormal
	lda <dataTitleScreenDlist2
	sta dlptr
	lda >dataTitleScreenDlist2
	sta dlptr+1
	jsr setTitleScreenHiScoreNMI
	jmp copyTitleTextsHiScore
.endp

.proc titleScreenMode3
	lda #25
	sta	titleScreen.screenDelay 
	jmp waitFrameNormal
.endp

.proc	copyTitleLogo
	lda #0
	tax
	ldy #91
@	txa
	sta bufScreen0+83,x
	tya
	sta bufScreen0+123,x
	iny
	inx
	cpx #34
	bne @-
	rts
.endp

.proc setTitleScreenNMI
	lda #0
	sta nmien       
	lda #<titleScreenDLI
	sta NMI.DLI+1
	lda #>titleScreenDLI
	sta NMI.DLI+2
	lda #<titleScreenVBL
	sta NMI.VBL+1
	lda #>titleScreenVBL
	sta NMI.VBL+2
	lda #$c0    
	sta nmien 
	rts
.endp

.proc setTitleScreenHiScoreNMI
	lda #0
	sta nmien   
	lda #<titleScreenHiScoreDLI
	sta NMI.DLI+1
	lda #>titleScreenHiScoreDLI
	sta NMI.DLI+2
	lda #$c0    
	sta nmien 
	rts
.endp

.proc	copyTitleTexts

	lda rapidusDetected
	beq txtPlay
	; or rapidus enabled
	lda #0 
	ldx #<titleScreenTexts.rapidus
	ldy #>titleScreenTexts.rapidus
	jsr copyText
	jmp nextText	
	; play
txtPlay
	lda #0 
	ldx #<titleScreenTexts.play
	ldy #>titleScreenTexts.play
	jsr copyText
nextText	
	; 1-up bonus
	lda #0
	ldx #<titleScreenTexts.bonus1
	ldy #>titleScreenTexts.bonus1
	jsr copyText
	lda #0
	ldx #<titleScreenTexts.bonus2
	ldy #>titleScreenTexts.bonus2
	jsr copyText
	
	; konami
	lda #0
	ldx #<titleScreenTexts.konami
	ldy #>titleScreenTexts.konami
	jsr copyText
	
	; NG
	lda #0
	ldx #<titleScreenTexts.newgen
	ldy #>titleScreenTexts.newgen
	jmp copyText
.endp

.proc	copyTitleTextsHiScore
	; score table
	lda #0 
	ldx #<titleScreenTexts.hiscore
	ldy #>titleScreenTexts.hiscore
	jmp copyText
.endp	

.proc titleScreenTexts
play	dta b(8),b(0),d'PLAY#'
rapidus	dta b(2),b(0),d'RAPIDUS ENABLED!#'
pause	dta b(0),b(0),d'       PAUSED       #'
pause2	dta b(3),b(0),d'OPTION TO QUIT#'
bonus1	dta b(0),b(1),d'1ST BONUS 10000 PTS.#'
bonus2	dta b(0),b(2),d'AND EVERY 50000 PTS.#'
konami	dta b(4),b(7),d'@1982 KONAMI#'
newgen	dta b(0),b(8),d'@2018 NEW GENERATION#'
hiscore dta b(0),b(1),d'SCORE RANKING TABLE '
			   	  dta d'1ST    10000   SOLO '
			   	  dta d'2ND     8800   LAOO '
			   	  dta d'3RD     8460   MIKER'
hiscoreMove	   	  dta d'4TH     6502   TIGER'
			   	  dta d'5TH     4300   VOY   #' 
.endp
