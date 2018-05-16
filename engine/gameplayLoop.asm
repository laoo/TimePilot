; ------------------
;   GAMEPLAY LOOP 
; ------------------
.proc gameplay
minFrames 				dta b(engineMinFrames)
animationSwitchDelay 	dta b(configAnimationSwitchDelay)

.proc	loop
	
	jsr prPrepareFrame
	jsr clearBufScreen
	jsr level.mainLoop
	jsr OLP.mainLoop
	jsr HIT.mainLoop
	jsr SPAWN.mainLoop

	jsr waitFrame
	
	; redraw score on screen every #configAnimationSwitchDelay loop iteration (saves cycles)
	lda animationSwitch	
	bne @+
	jsr SCORE.scoreShow
	jsr SCORE.hiScoreRewrite
	jsr SCORE.extraLife

@	toggleBufScreenNr		; MADS macro
	
	lda gamePaused
	beq @+
	jsr gameplay.pause
@	
	jsr gameplay.nextLoop
	jmp gameplay.loop
.endp	

.proc nextLoop
		; animation switcher
		dec animationSwitchCounter
		bne fpsLock
		
		lda animationSwitch
		eor #1
		sta animationSwitch
		lda animationSwitchDelay
		sta animationSwitchCounter

fpsLock	
		; FPS LOCK
		lda frameCounter			
		cmp minFrames
		bcc fpsLock		
@
		;!##TRACE "frames: %d" db(frameCounter)
		lda #0
		sta frameCounter
		
		; jsr DEBUG.show

		; extra life subsong channel swap
		lda extraLifeDuration
		beq @+
		dec extraLifeDuration
		bne @+
		lda <soundSystem.soundChannelSFX			; extralife subsong done - move enemy shots sfx back to channel 0
		sta SPAWN.enemyShots.shotSoundNumber+5
		sta SPAWN.enemyBombs.shotSoundNumber+5
@	
		rts
	
.endp	

.proc pause
	lda #<bufScreenTxt
	sta _CopyFrom
	sta swap					; A=0
	lda #>bufScreenTxt
	sta _CopyFrom+1
	lda #<buf2FreePages
	sta _CopyTo
	lda #>buf2FreePages
	jsr cont

	lda #1
	sta delay
		
pauseLoop	
	lda gamePaused
	beq unpause	
	
	jsr waitFrameNormal

	dec delay
	bne @+
	lda #60
	sta delay
	lda swap
	eor #1
	sta swap
@	
	lda swap
	beq txt2
	lda #0 
	ldx #<titleScreenTexts.pause
	ldy #>titleScreenTexts.pause
	jsr copyText
	beq @+
txt2
	lda #0 
	ldx #<titleScreenTexts.pause2
	ldy #>titleScreenTexts.pause2
	jsr copyText
@	
	lda consol										; option key during pause - back to title screen
	beq levelSkipper
	cmp #3
	bne pauseLoop
	jmp main
	
unPause
	lda #<buf2FreePages
	sta _CopyFrom
	lda #>buf2FreePages
	sta _CopyFrom+1
	lda #<bufScreenTxt
	sta _CopyTo
	lda #>bufScreenTxt
cont	
	sta _CopyTo+1
	ldy #20-1
	jmp memCopyShort

swap	dta b(0)
delay	dta b(1)

.proc levelSkipper
	jsr unPause
	lda #0
	sta gamePaused
	lda #1
	sta levelCurrent.bossKilled
	rts
.endp

.endp

.endp
