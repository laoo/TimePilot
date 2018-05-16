; TIMEPILOT Joystick VBL

.proc playfieldJoystickVBL
	
	;PAUSE
	lda gamePauseDelay
	beq pause
	dec gamePauseDelay
	bne joystick
pause
	lda consol
	cmp #6								; start key
	beq doPause
	lda skstat
	and #$04
	bne joystick
	
doPause
	lda #configPauseDelay
	sta gamePauseDelay
	lda gamePaused
	eor #1
	sta gamePaused
	jsr RMT.rmt_silence
	
joystick
	lda playerDestroyed					; if player is destroyed - we ignore joystick/fire
	beq @+
	rts
@	
	lda gamePaused						; if game is paused - we ignore joystick/fire
	beq @+
	rts
@	
	;JOYSTICK

	lda levelCurrent.allowSpawns		; can we even spawn a shot?
	beq joyMovement
	lda playerShotCounter
	cmp #engimeMaxPlayerShots			; are max shot already spawned?
	bcs joyMovement
	dec playerShotDelay
	bne joyMovement
	lda #1
	sta playerShotDelay
	lda trig0
	tax
	beq doShot
	lda #configPlayerShotMaxChain		; resets shot chain if fire button is not pressed
	sta playerShotChain
	jmp joyMovement		
	
doShot	
	lda playerShotChain					; do not shot if max chain is reached until fire button is released
	beq joyMovement
	dec playerShotChain
	lda #configPlayerShotDelay
	sta playerShotDelay

	jsr spawn.playerShot
				
joyMovement	
	lda playerMovementAllow
	bne @+
	rts
@	; movemenet
	lda porta
	tax
	eor #$ff
	bne joy
	
	lda #1		; joy0 neutral position => reset delay counter to 1 (to prevent input lag)
	sta player.animationDelay	
	rts 	
	
joy	txa			; todo: check playerAnimationDelay first?
	eor #$ff
	and #$f
	tax
	lda joyPlayerFrameTable,x
	cmp player.currentFrame 	; do animation if current frame != destination frame
	bne checkAnimationDelay
	rts 
checkAnimationDelay	
	dec player.animationDelay
	beq doAnimation				
	rts			; do nothing until animation delay ends

doAnimation
	tax 					; X =	destination frame
 	; exceptions
	lda player.lastFrame
	cmp #3
	beq exceptionOne
	cmp #13
	beq exceptionOne
	
	cmp #11
	beq exceptionTwo
	cmp #5
	beq exceptionTwo
	
	cmp #1
	beq exceptionThree
	cmp #7
	beq exceptionThree
	
	cmp #15
	beq exceptionFour
	cmp #9
	beq exceptionFour
	bne exceptionsEnd
exceptionOne
	lda #1
	sta joyPlayerRotationTable + $c4
	lda #0
	sta joyPlayerRotationTable + $4c
	beq exceptionsEnd
exceptionTwo	
	lda #0
	sta joyPlayerRotationTable + $c4
	lda #1
	sta joyPlayerRotationTable + $4c
	bne exceptionsEnd
exceptionThree
	lda #1
	sta joyPlayerRotationTable + $08
	lda #0
	sta joyPlayerRotationTable + $80
	beq exceptionsEnd	
exceptionFour
	lda #0
	sta joyPlayerRotationTable + $08
	lda #1
	sta joyPlayerRotationTable + $80		
exceptionsEnd	

	; rotation
	clc
	lda player.currentFrame
	sta player.lastFrame
	asl @
	asl @
	asl @
	asl @
	sta joyPlayerVar1
	txa
	clc
	adc joyPlayerVar1
	tax

	lda joyPlayerRotationTable,x
	bne a1
	dec player.currentFrame
	jmp a2			 
a1	inc player.currentFrame
	
a2	lda player.currentFrame
	and #$f
	sta player.currentFrame
	
	lda #configPlayerAnimationDelay
	sta player.animationDelay
	
	lda #1
	sta playerFrameDraw
	rts

joyPlayerVar1 dta b(0)

; PORTA JOY0 value -> player destination frame 	
joyPlayerFrameTable 
	dta b(0) 	; 0 = 
	dta b(0) 	; 1 = up		
	dta b(8) 	; 2 = down
	dta b(0) 	; 3 =  
	dta b(12)	; 4 = left		
	dta b(14) 	; 5 = up/left
	dta b(10) 	; 6 = down/left
	dta b(0)	; 7 =
	dta b(4)	; 8 = right
	dta b(2) 	; 9 = up/right
	dta b(6) 	; 10 = down/right

; joyPlayerRotationTable for arcade version tweaks (not regular - it has exceptions)
; current frame -> destination frame table (inc/dec)
; 1 = inc | 0 = dec | 16 x 16
; table because we can easly modify what direction we want to take

joyPlayerRotationTable
	dta b(0),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0),b(0),b(0),b(0)	; 0 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(0),b(0),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0),b(0),b(0)	; 1 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(0),b(0),b(0),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0),b(0)	; 2 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(0),b(0),b(0),b(0),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0)	; 3 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(0),b(0),b(0),b(0),b(0),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0)	; 4 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(0),b(0),b(0),b(0),b(0),b(0),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(0),b(0)	; 5 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(0)	; 6 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(1)	; 7 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

	dta b(1),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(1),b(1),b(1),b(1),b(1),b(1),b(1)	; 8 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(1),b(1),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(1),b(1),b(1),b(1),b(1),b(1)	; 9 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(1),b(1),b(1),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(1),b(1),b(1),b(1),b(1)	; 10 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(1),b(1),b(1),b(1)	; 11 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(1),b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(1),b(1),b(1)	; 12 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(1),b(1),b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(1),b(1)	; 13 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(1)	; 14 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dta b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(1),b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)	; 15 frame to 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
.endp
	