;	TIMEPILOT
;	score routines

.proc	SCORE

; BCD mode
; A = value to add in BCD (1-99) *100 (minimum value in game is 100)
; A = 20 => score+=2000
.proc scoreAdd
	clc
	sed
	pha
	adc playerScore
	sta playerScore
	bcc @+
	lda playerScore+1
	adc #0					; c is set
	sta playerScore+1
@	
	pla
	adc extraLifeScore
	sta extraLifeScore
	bcc @+
	lda extraLifeScore+1
	adc #0					; c is set
	sta extraLifeScore+1
@
	cld
	rts
.endp

.proc scoreShow
posX equ 14		; score position on screen

	clc
	lda playerScore+1
	pha
	and #$f0
	lsr 
	lsr
	lsr
	lsr
	adc #16
	sta bufScreenTxt+posX
	pla
	and #$f
	adc #16
	sta bufScreenTxt+posX+1
	
	lda playerScore
	pha
	and #$f0
	lsr 
	lsr
	lsr
	lsr
	adc #16
	sta bufScreenTxt+posX+2
	pla
	and #$f
	adc #16
	sta bufScreenTxt+posX+3
	
	; temporaly - clear first zeros
	ldy #0
@	lda bufScreenTxt+posX,y
	cmp #16			; ='0'
	bne cleared
	lda #0
	sta bufScreenTxt+posX,y
	iny
	cpy #4
	bne @-
cleared
	rts
	
.endp

.proc hiScoreRewrite
	lda hiScoreNew			; player got higscore? we wont compare again
	bne rewrite
	
	; BCD 16BIT compare player score vs highscore
	lda playerScore
	cmp SCORE.highScoreTableL
	lda playerScore+1
	sbc SCORE.highScoreTableH
	bcc noHiscore
	inc hiScoreNew
	
rewrite	
	ldy #0
	ldx #scoreShow.posX
@
	lda bufScreenTxt,x
	sta bufScreenTxt+3,y
	inx
	iny
	cpy #6
	bne @-
noHiscore
	rts
.endp

.proc extraLife
	lda extraLifeScore+1
	cmp extraLifeValue
	bcc noExtraLife
addLife
	lda #5
	sta extraLifeValue							; next extra life after 50.000
	lda #0			
	sta extraLifeScore
	sta extraLifeScore+1
	inc playerLives
	
	lda levelCurrent.bossKilled
	bne @+										; skip extralife song if boss is killed (teleport songs will be played instead)
	lda <soundSystem.soundChannelSFX+1			; move enemy shots sfx to channel1 until extralife subsong is done
	sta SPAWN.enemyShots.shotSoundNumber+5
	sta SPAWN.enemyBombs.shotSoundNumber+5
	lda #$10
	jsr sound.soundInit.changeSong
	jsr fixBossSound
	lda extraLifeDurationValue					; subsong duration (in gameloop iterations)
	sta extraLifeDuration 
@	jmp level.showPlayerLives	

noExtraLife
	rts
extraLifeDurationValue	dta b(44)
.endp

; --------------------
;	HIGHSCORE INIT
; IN: X = highscore position/line
; --------------------	
.proc highScoreInit
copyFrom	equ zeroPageLocal
copyTo		equ zeroPageLocal+2
lines		equ	zeroPageLocal+5

 	cpx #4
 	bcs lastPosition
 	
 	; copy older highscores 1 line below
	lda linesToCopy,x
	sta lines
	lda #<titleScreenTexts.hiscoreMove	
	sta copyFrom
	lda #>titleScreenTexts.hiscoreMove
	sta copyFrom+1
	
	lda copyFrom
	sta copyTo
	lda copyFrom+1	
	sta copyTo+1
	adw copyTo #20
	
	ldx lines
line	
	ldy #3 	; skip first 3 bytes of every line ('1ST', '2ND' etc)
@	lda (copyFrom),y
	sta (copyTo),y
	iny
	cpy #20
	bcc @-
	sbw copyFrom #20
	sbw	copyTo #20
	dex
	bne line	
	
	; copy older highscore values 1 line below
	ldy lines
	ldx #4
@	lda highScoreTableL,x
	sta highScoreTableL+1,x
	lda highScoreTableH,x
	sta highScoreTableH+1,x
	dex
	dey
	bpl @-	
		
lastPosition
	; copy player score to highscore values table
	ldx SCORE.highScoreLine
	lda playerScore
	sta SCORE.highScoreTableL,x
	lda playerScore+1
	sta SCORE.highScoreTableH,x
	 	
	inc doHighScoreFlag
	ldx #5
@	lda bufScreenTxt+14,x
	sta newHighScore,x
	dex
	bpl @-
	rts
linesToCopy	dta b(4),b(3),b(2),b(1)
.endp	

; -----------------------------
;	FIND HIGHSCORE
; OUT: A>0 - we got highscore
; -----------------------------
.proc findHighScore
	ldx #$ff
@	inx
	cpx #5
	bcs noHigh
	lda playerScore
	cmp SCORE.highScoreTableL,x
	lda playerScore+1
	sbc SCORE.highScoreTableH,x
	bcc @-
	stx SCORE.highScoreLine		; cache - used in doHighScore
	lda #1 
	rts		
noHigh	
	lda #0 
	rts
	
.endp

; ----------------------		
;	  DO HIGHSCORE
; ----------------------	
.proc	doHighScore
screenLine		equ zeroPageLocal 		; 2 bytes
titleScreenLine	equ zeroPageLocal+2		; 2 bytes
hiscoreLine		equ zeroPageLocal+4 	; 2 bytes

	lda #$21 							; 'A'
	sta letter
	sta letterCurrent
		
	lda #2
	sta titleScreen.screenMode
	jsr setTitleScreenNMI
	jsr titleScreenMode2
	
	lda #>bufScreenTxt	
	sta screenLine+1
	lda #<bufScreenTxt
	sta screenLine
	
	ldx SCORE.highScoreLine				; line position on screen for new highscore
	inx							
@	adw screenLine #20
	dex
	bpl @-
	
	lda #0
	sta letterCounter
	ldx #4								; clear old highscore nickname
	ldy #15
@	sta (screenLine),y
	iny
	dex 
	bpl @-
	
	ldx #5								; put new highscore on screen
	ldy #11
@	lda SCORE.newHighScore,x
	sta (screenLine),y
	dey
	dex
	bpl @-
	
	lda #configMusicHighScore
	jsr sound.soundInit.changeSong
	
	ldy #15
hiLoop	
	lda letter
	eor letterCurrent
	sta letter
	sta (screenLine),y
	
	lda changeLetterDelay
	beq @+
	dec changeLetterDelay
	ldx #changeLetterDelayValue
	jsr waitXFrames
@	
	jsr deleteLetter
	jsr nextLetter
	jsr changeLetter

	ldx #10
	jsr waitJoyXFrames
	cpy #20
	bcc hiLoop
	
finish 
	; rewrite highscore to titlescreen string
	lda #>titleScreenTexts.hiscore	
	sta titleScreenLine+1
	lda #<titleScreenTexts.hiscore	
	sta titleScreenLine
	adw titleScreenLine #2
	
	lda #>playfieldTexts.score2
	sta hiscoreLine+1
	lda #<playfieldTexts.score2
	sta hiscoreLine
	sbw hiscoreLine #4
	
	ldx SCORE.highScoreLine				; line position on screen for new highscore						
@	adw titleScreenLine #20
	dex
	bpl @-

	ldy #6
scoreRewrite
	lda (screenLine),y
	sta (titleScreenLine),y
	iny
	cpy #12
	bcs @+
	ldx SCORE.highScoreLine	
	bne @+
	sta (hiscoreLine),y					; 1st place highscore rewrite for playfield
@	
	cpy #20
	bcc scoreRewrite
	
	ldx #50
	jsr waitXFrames
	lda #0
	sta doHighScoreFlag
	sta titleScreen.screenMode
	lda #0
	jsr sound.soundInit.changeSong
	jmp main

.proc 	nextLetter							; joy trigger pressed - move to next letter
	lda trig0
	bne @+
	lda #soundNumber
	sta soundSystem.soundChannelSFX+3
	lda #soundNote
	sta soundSystem.soundChannelNote+3
	inc letterCounter
	lda letterCurrent
	sta (screenLine),y
	ldx #18
	jsr waitXFrames
	iny
@	rts
.endp

.proc 	deleteLetter						; delete letter (joy left)
	lda letterCounter
	beq @+
	lda porta
	eor #$ff
	and #$f
	cmp #4 	
	bne @+
	lda #soundNumberDelete
	sta soundSystem.soundChannelSFX+3
	lda #soundNote
	sta soundSystem.soundChannelNote+3
	dec letterCounter
	lda #0
	sta (screenLine),y
	ldx #18
	jsr waitXFrames
	dey
@	rts
.endp

.proc	changeLetter					; empty space in highscore added by Nir Dary
	lda porta
	eor #$ff
	and #$f
	tax
	cpx #1 			            		; joyUp
	bne @+
	ldx letterCurrent
	cpx #$3a							; 'Z' ($3a)
	bcs doNothing
	cpx #00               				; Check for Space Charecter
	bne notspace1                   
	lda #$20                          
	sta letterCurrent               
notspace1                           
	inc letterCurrent
	lda #0
	sta letter
	inc changeLetterDelay
	rts
	
@	cpx #2								; joyDown
	bne doNothing
	ldx letterCurrent
	cpx #$20							; 'A' ($21)
	beq doNothing
	cpx #00                       		; check for space charecter
	bne notspace2                
	lda #$21                      		; after space comes 'A'
	sta letterCurrent              
notspace2                             
	dec letterCurrent              
	lda letterCurrent             
	cmp #$20                     		; one below 'A'
	bne space                     
	lda #0                        
	sta letterCurrent              		; insert space
space                              
	lda #0
	sta letter
	inc changeLetterDelay
	rts
doNothing	
	rts
.endp
	
letter 		  dta b($21)	; 'A'
letterCurrent dta b($21)
letterCounter dta b(0)
changeLetterDelay		 	dta b(0)
changeLetterDelayValue		equ 6	
soundNumber					equ 4
soundNumberDelete			equ 2
soundNote					equ 0
.endp

doHighScoreFlag	dta b(0)
newHighScore		dta '      '			; buffer for new highscore

; BCD highscores
highScoreTableL dta b($0), b($88), b($84), b($65), b($43), b(0)	; last value is for temporary buffer 
highScoreTableH	dta b($1), b(0), b($0), b($0), b($0), b(0)		
highScoreLine	dta b(0)								
.endp
 
 