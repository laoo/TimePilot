; OLP
; Object List Processing

.proc	OLP	
; init			init OLP system
; mainLoop		processing objects - main loop
; playerShots 	process player shots
; enemies		process enemies
; enemyShots	process enemy shots
; enemyBombs	process enemy bombs
; explosions	process explosions		
; parachute		process parachute
; cloudSmall	process small clouds
; cloudMedium	process medium clouds
; cloudBig		process big clouds
; boss			process boss

; -----------------------------------------
;	MAIN LOOP - jump here every gameLoop
;		 processing order matters
; -----------------------------------------
.proc mainLoop
	jsr OLP.cloudSmall	
	jsr OLP.cloudMedium
	jsr OLP.parachute
	jsr OLP.explosions
	jsr OLP.enemies
	jsr OLP.enemyBombs
	jsr OLP.enemyShots
	jsr OLP.boss
	jsr OLP.cloudBig
    jsr drawPlayer
	jmp OLP.playerShots
.endp

; ----------------------
;	 PROCESS: ENEMIES 
; ----------------------
.proc	enemies	
	lda enemyCounter
	bne @+
	rts
@	
  	ldy #prPrepareGenericTypes.enemy
 	jsr prPrepareGeneric

	lda #(olCommon+engineMaxCommon-1)
	sta OLPCounter
loop
	ldx OLPCounter
	lda ol.tab.type,x		
	cmp #ol.type.enemy
	bne nextObject
	ldx OLPCounter
	jsr objectVelocityMovement
	jsr objectGlobalVelocityMovement
	jsr prDrawEnemy
	pha
	ldx OLPCounter	
	jsr genericFadeOut
	bne @+
	dec enemyCounter
@	
	pla
	cmp #1
	bne noCollision
	
	; colission player -> enemy | hitbox test
	jsr HIT.hitPlayerEnemy
	beq noCollision
		
	inc playerDestroyed
	ldx OLPCounter
	lda #ol.type.explosion
	sta ol.tab.type,x
	lda #0
	sta ol.tab.animationCounter,x
	jsr SPAWN.playerExplosion
	
noCollision	
	jsr enemyRotation
	
nextObject
	dec OLPCounter
	lda OLPCounter
	cmp maxEnemiesOLP	
	bne loop
	rts
	
maxEnemiesOLP	dta b(olCommon+engineMaxCommon-1-engineMaxEnemies)
		
.endp

; ----------------------
;	 PROCESS: ENEMYSHOTS 
; ----------------------
.proc	enemyShots	
	lda enemyShotCounter
	bne @+
	rts	
@		
	lda #olEnemyShots
	sta OLPCounter
	lda #0
	sta shotNumber+1
loop
	ldx OLPCounter
	lda ol.tab.type,x		
	beq nextObject
	
	ldx OLPCounter
	jsr objectVelocityMovement
	lda player.currentFrame
	cmp ol.tab.globalVelocitySpawnFrame,x
	beq @+
	jsr objectGlobalVelocityMovement
	jsr objectCounterGlobalVelocityMovement
@	
	lda ol.tab.posXH,x
	sta enemyFire.draw.xPos
	lda ol.tab.posYH,x
	sta enemyFire.draw.yPos
shotNumber
	lda #0
	jsr enemyFire.clear
	jsr enemyFire.draw		
	bpl hitTest  

	; out of bound - destroy enemyshot
	lda shotNumber+1
	jsr enemyFire.clear
	dec enemyShotCounter
	ldx OLPCounter
	lda #0
	sta ol.tab.type,x
	beq nextObject

	; hit detection
hitTest	
	jsr enemyFire.hitTest
	bmi nextObject
	lda playerDestroyed				; if player is destroyed - we ignore hit detection
	bne nextObject
	
	; hit detect
	pha
	jsr enemyFire.hitClear
	jsr enemyFire.clear
	jsr SPAWN.playerExplosion
	pla
	tax
	lda #0
	sta ol.tab.type+olEnemyShots,x  ; destroy enemyShot | X = shot number
	inc playerDestroyed
	
nextObject
	inc shotNumber+1
	inc OLPCounter
	lda OLPCounter
	cmp #(engimeMaxEnemyShots+olEnemyShots)		
	bne loop
	rts
.endp

; -------------------------
;	 PROCESS: EXPLOSIONS 
; -------------------------
.proc	explosions	

  	ldy #prPrepareGenericTypes.explosion
  	jsr prPrepareGeneric
	lda #olCommon
	sta OLPCounter
	
loop
	ldx OLPCounter
	lda ol.tab.type,x		
	cmp #ol.type.explosion
	bne nextObject
	
	lda ol.tab.animationCounter,x
auto0	
	nop							; lsr if rapidus
	tay
	lda explosionFrame,y
	cmp #$ff
	bne @+
	lda #0						; explosion animation ends => destroy the object
	sta ol.tab.type,x		
	beq nextObject
@
	lda explosionFrame,y
	sta ol.tab.frame,x
	inc ol.tab.animationCounter,x
	
	ldx OLPCounter
	jsr objectGlobalVelocityMovement
	jsr prDrawObject

nextObject
	inc OLPCounter
	lda OLPCounter
	cmp #(engineMaxCommon+olCommon)		
	bne loop
	rts

explosionFrame dta b(0),b(0),b(1),b(1),b(2),b(2),b(3),b(3),b(3),b(2),b(2),b(1),b(1),b(0),b(0),($ff)	; real animation frames
.endp

; -------------------------
;	 PROCESS: ENEMY BOMBS
; -------------------------
.proc	enemyBombs
	lda enemyBombCounter
	bne @+
	rts
@	
  	ldy #prPrepareGenericTypes.bomb
  	jsr prPrepareGeneric
	lda #olCommon
	sta OLPCounter
loop
	ldx OLPCounter
	lda ol.tab.type,x		
	cmp #ol.type.bomb
	bne nextObject

	lda gameCurrentLevel					; lvl 5 - ufo missile animation swap (0/1)
	cmp #5
	bne @+
	lda ol.tab.frame,x	
	eor #1
	sta ol.tab.frame,x
	
@	ldx OLPCounter
	jsr objectGlobalVelocityMovement
	jsr enemyBomb.process					; calculate new velocity for bomb
	jsr objectVelocityMovement
	jsr prDrawObject
	
	pha
	ldx OLPCounter	
	jsr genericFadeOut
	bne @+
	dec enemyBombCounter
@	
	pla
	cmp #1
	bne noCollision
	
	; colission player -> bomb | hitbox test
	jsr HIT.hitPlayerBomb
	beq noCollision

	inc playerDestroyed
	ldx OLPCounter
	lda #ol.type.explosion
	sta ol.tab.type,x
	lda #0
	sta ol.tab.animationCounter,x
	lda ol.tab.posXH+olCommon,x				; center explosion on bomb (the bomb is smaller)
	sbc #8
	sta ol.tab.posXH+olCommon,x
	lda ol.tab.posYH+olCommon,x
	sbc #8
	sta ol.tab.posYH+olCommon,x
	jsr SPAWN.playerExplosion
	
noCollision

nextObject
	inc OLPCounter
	lda OLPCounter
	cmp #(engineMaxCommon+olCommon)		
	bne loop
	rts

explosionFrame dta b(0),b(0),b(1),b(1),b(2),b(2),b(3),b(3),b(3),b(2),b(2),b(1),b(1),b(0),b(0),($ff)	; real animation frames
.endp

; -------------------------
;	 PROCESS: PARACHUTE
; -------------------------
.proc	parachute

	lda ol.tab.type+olParachute
	beq skip
	
  	ldy #prPrepareGenericTypes.parachute
  	jsr prPrepareGeneric

	lda parachuteDestroyDelay
	beq @+
	lda #4
	sta ol.tab.frame+olParachute
	dec parachuteDestroyDelay
	bne movement
	lda #0
	sta ol.tab.type+olParachute
	lda <soundSystem.soundChannelSFX				; parachute subsong done - move enemy shots sfx to channel0
	sta SPAWN.enemyShots.shotSoundNumber+5
	rts
@		
	lda ol.tab.animationCounter+olParachute
auto0	
	nop												; lsr if rapidus
	tay
	lda parachuteFrame,y
	cmp #$ff
	bne @+
	lda #0
	sta ol.tab.animationCounter+olParachute 		; loop parachute animation
	tay
@	
	lda parachuteFrame,y
	sta ol.tab.frame+olParachute
	inc ol.tab.animationCounter+olParachute

movement
	ldx #olParachute
	jsr objectVelocityMovement
	jsr objectGlobalVelocityMovement
	jsr prDrawObject
	pha	
	ldx #olParachute
	jsr genericFadeOut
	pla
	cmp #1
	bne skip	; no colission

	; check colission with player
	lda ol.tab.frame+olParachute
	cmp #4
	bcs skip
	
	lda ol.tab.posXH+olParachute
	cmp #colX1
	bcc skip
	cmp #colX2
	bcs skip
	lda ol.tab.posYH+olParachute
	cmp #colY1
	bcc skip
	cmp #colY2
	bcs skip
	lda playerDestroyed							; if player is destroyed - we ignore parachute colission
	bne skip
	beq parachuteGrabbed
	
skip
	rts

parachuteGrabbed
 	lda SPAWN.parachute.destroyDelay
	sta parachuteDestroyDelay
	lda <soundSystem.soundChannelSFX+1			; move enemy shots sfx to channel1 until subsong is done
	sta SPAWN.enemyShots.shotSoundNumber+5
	lda #2
	jsr sound.soundInit.changeSong
	jsr fixBossSound
	lda #gameParachuteScore
	jmp SCORE.scoreAdd
	

parachuteFrame dta b(0),b(0),b(0),b(0)
			   dta b(1),b(1),b(1),b(1)
			   dta b(2),b(2),b(2),b(2)
			   dta b(3),b(3),b(3),b(3)
			   dta b(2),b(2),b(2),b(2)
			   dta b(1),b(1),b(1),b(1)
			   dta b($ff)	
soundNumber			equ 4
soundNote			equ 0			   
colX1   equ prScreenXMin+prScreenWidth/2-16
colX2   equ prScreenXMin+prScreenWidth/2+8
colY1   equ prScreenYMin+prScreenHeight/2-16  
colY2   equ prScreenYMin+prScreenHeight/2+8
.endp


; ----------------------------
;	 PROCESS: PLAYER SHOTS
; ----------------------------
.proc playerShots		

	lda #(olPlayerShots+engimeMaxPlayerShots-1)
	sta OLPCounter
loop
	ldx OLPCounter
	lda ol.tab.type,x			; no object on list - skip
	beq nextObject
	
	ldx OLPCounter
	jsr objectVelocityMovement
	jsr prDrawPlayerFire
	
skip
	ldx OLPCounter
	jsr genericFadeOut
	; bne nextObject

nextObject
	dec OLPCounter
	bpl loop
	rts
.endp	; objectsPlayerShots

; ----------------------------
;	 PROCESS: BOSS
; ----------------------------
.proc boss

	lda ol.tab.type+olBoss
	beq skip

  ldy #prPrepareGenericTypes.boss
  jsr prPrepareGeneric
	lda levelCurrent.enemyBossHP
	cmp levelCurrent.enemyBossHalfHP
	bcs @+ 
	lda random
	and #1
	sta ol.tab.frame+olBoss

@	
	ldx #olBoss
	jsr objectVelocityMovement
	jsr objectGlobalVelocityMovement
	jsr prDrawObject
	ldx #0
	stx prPrepareGeneric.bossBlink
	cmp #1
	bne noCollision
	
	; colission player -> boss | hitbox test
	jsr HIT.hitPlayerBoss
	beq noCollision
	inc playerDestroyed
	inc levelCurrent.BossKilled
	inc levelCurrent.explodeAll
	lda #0
	sta ol.tab.type+olBoss

noCollision

skip
	rts
.endp

; ----------------------------
;	 PROCESS: SMALL CLOUD
; ----------------------------
.proc cloudSmall
	lda cloudCounter1
	bne @+
	rts
@	
type = *+1
  ldy #prPrepareGenericTypes.cloud1
  jsr prPrepareGeneric

	lda #olClouds
	sta OLPCounter
loop
	ldx OLPCounter
	lda ol.tab.type,x			; no object on list - skip
	cmp #ol.type.cloud1
	bne nextObject
	
	dec	ol.tab.movementDelay,x	; small cloud movemenet delay
	bne @+
	lda #2
	sta ol.tab.movementDelay,x
	jsr objectGlobalVelocityMovement
@	
	jsr prDrawObject
	ldx OLPCounter
	jsr genericFadeOut	
	bne nextObject
	dec cloudCounter1		

nextObject
	inc OLPCounter
	lda OLPCounter
	cmp SPAWN.maxCloudsSpawnFol		
	bne loop
	rts
delay dta b(0)
.endp

; ----------------------------
;	 PROCESS: MEDIUM CLOUD
; ----------------------------
.proc cloudMedium
	lda cloudCounter2
	bne @+
	rts
@	
type = *+1
  ldy #prPrepareGenericTypes.cloud2
  jsr prPrepareGeneric

	lda #olClouds
	sta OLPCounter
loop
	ldx OLPCounter
	lda ol.tab.type,x			; no object on list - skip
	cmp #ol.type.cloud2
	bne nextObject
	
	ldx OLPCounter
	jsr objectGlobalVelocityMovement
	jsr prDrawObject
	ldx OLPCounter
	jsr genericFadeOut	
	bne nextObject
	dec cloudCounter2
	
nextObject
	inc OLPCounter
	lda OLPCounter
	cmp SPAWN.maxCloudsSpawnFol		
	bne loop
	rts
.endp

; ----------------------------
;	 PROCESS: BIG CLOUD
; ----------------------------
.proc cloudBig
	lda cloudCounter3
	bne @+
	rts
@	
type = *+1
  ldy #prPrepareGenericTypes.cloud3
  jsr prPrepareGeneric

	lda playerMaskTouched
	beq @+
	jsr resetPlayerMask
	ldx #0
	stx playerMaskTouched
	inx
	stx playerFrameDraw
@
	
	lda #olClouds
	sta OLPCounter
loop
	ldx OLPCounter
	lda ol.tab.type,x			; no object on list - skip
	cmp #ol.type.cloud3
	bne nextObject
	
	ldx OLPCounter
	jsr objectGlobalVelocityMovement
	jsr objectGlobalVelocityMovement
	jsr prDrawObject
	ldx OLPCounter
	jsr genericFadeOut	
	bne nextObject
	dec cloudCounter3

nextObject
	inc OLPCounter
	lda OLPCounter
	cmp SPAWN.maxCloudsSpawnFol		
	bne loop
	rts
.endp

; -------------------------------
;	INIT - init the OLP system
; -------------------------------
.proc init
	; clear OL tables
	lda #0
	tax
loop
	sta ol.base,x
	sta ol.base+$100,x
	sta ol.base+$200,x
	inx
	bne loop
	rts
.endp 	; objectListProcessingInit


; *****************************************
; ********   PRIVATE OLP ROUTINES   *******
; *****************************************

; --------------------------------
;	OBJECT VELOCITY MOVEMENT 
;	X - object number
;	Y - mode; 0 
; --------------------------------
.proc	objectVelocityMovement
	clc					
	lda ol.tab.posXL,x
	adc ol.tab.velXL,x
	sta ol.tab.posXL,x
	lda ol.tab.posXH,x
	adc ol.tab.velXH,x
	sta ol.tab.posXH,x
	
	clc					
	lda ol.tab.posYL,x
	adc ol.tab.velYL,x
	sta ol.tab.posYL,x
	lda ol.tab.posYH,x
	adc ol.tab.velYH,x
	sta ol.tab.posYH,x
	rts
.endp	; objectVelocityMovement


; ------------------------------------
;  OBJECT GLOBAL VELOCITY MOVEMENT
;  adds	player velocity
;  X - object number
; ------------------------------------
.proc	objectGlobalVelocityMovement
	
	ldy player.currentFrame
	clc
	lda ol.tab.posXL,x
	adc globalVelocityXL,y
	sta ol.tab.posXL,x
	lda ol.tab.posXH,x
	adc globalVelocityXH,y
	sta ol.tab.posXH,x
	
	clc					
	lda ol.tab.posYL,x
	adc globalVelocityYL,y
	sta ol.tab.posYL,x
	lda ol.tab.posYH,x
	adc globalVelocityYH,y
	sta ol.tab.posYH,x
	rts
.endp

.proc objectCounterGlobalVelocityMovement
	
	lda ol.tab.globalVelocitySpawnFrame,x
	tay
	
	sec					
	lda ol.tab.posXL,x
	sbc globalVelocityXL,y
	sta ol.tab.posXL,x
	lda ol.tab.posXH,x
	sbc globalVelocityXH,y
	sta ol.tab.posXH,x
	
	sec					
	lda ol.tab.posYL,x
	sbc globalVelocityYL,y
	sta ol.tab.posYL,x
	lda ol.tab.posYH,x
	sbc globalVelocityYH,y
	sta ol.tab.posYH,x
	rts
.endp	

globalVelocityTab	; it is copied to globalVelocityXH (...) zeropage buffer
	dta h(+$000),h(-$40),h(-$100),h(-$120),h(-$120),h(-$100),h(-$100),h(-$080), h(+$000),h(+$90),h(+$f4),h(+$120),h(+$120),h(+$100),h(+$100),h(+$40)  
	dta h(+$100),h(+$100),h(+$100),h(+$70),h(+$000),h(-$c0),h(-$100),h(-$100), h(-$100),h(-$100),h(-$e4),h(-$50),h(+$000),h(+$b0),h(+$100),h(+$100)
	dta l(+$000),l(-$40),l(-$100),l(-$120),l(-$120),l(-$100),l(-$100),l(-$080), l(+$000),l(+$90),l(+$f4),l(+$120),l(+$120),l(+$100),l(+$100),l(+$40)
	dta l(+$100),l(+$100),l(+$100),l(+$70),l(+$000),l(-$c0),l(-$100),l(-$100), l(-$100),l(-$100),l(-$e4),l(-$50),l(+$000),l(+$b0),l(+$100),l(+$100)	
globalVelocityXH		equ zeropage+$40 ; $10 bytes
globalVelocityYH		equ zeropage+$50 ; $10 bytes
globalVelocityXL		equ zeropage+$60 ; $10 bytes
globalVelocityYL		equ zeropage+$70 ; $10 bytes

; ---------------------------------------------------------------
;	GENERIC FADEOUT - used in most cases
;	In:
;	X - object number
;	A - #$ff object outOfBounds , lets fadeOut
;	Out:
;	A=0 if object destroyed, A=1 if not destroyed
; ---------------------------------------------------------------
.proc	genericFadeOut
	cmp #$ff 				; do not use BMI here
	bne @+		
	dec ol.tab.fadeOut,x	; object outOfBounds - lets fadeOut
	bne @+
	lda #0
	sta ol.tab.type,x		; fade out kicks in - destroy object
	rts
	
@	lda #1					; object not destroyed
	rts
.endp	; genericFadeOut


; --------------------------------------
;	 ROTATE OBJECT (16 animation frames)
;  X = object number in ol.tab 
; --------------------------------------
.proc enemyRotation
	; rotation
	lda ol.tab.frame,x
	cmp ol.tab.rotationTargetFrame,x
	bne rotate

	; rotation done - set new target frame for rotation
	dec ol.tab.agilityDelay,x
	bne skipRotation
	lda random
	and levelCurrent.agilityDelay
	adc levelCurrent.agilityMinimum
	sta ol.tab.agilityDelay,x
	lda random
	and #1
	beq @+
	lda #{iny}
	bne dir
@
	lda #{dey}
	sta ol.tab.rotationDirection,x
dir	
	lda random
	and #15
	sta ol.tab.rotationTargetFrame,x
	bmi skipRotation
	
rotate	
	dec ol.tab.rotationDelay,x
	bne skipRotation
	lda random
	and levelCurrent.rotationDelay
	adc levelCurrent.rotationDelayMin
	sta ol.tab.rotationDelay,x
	
	lda ol.tab.rotationDirection,x
	sta direction 
	ldy ol.tab.frame,x
direction	
	iny				; iny/dey depends on firection
	tya
	and #15
	sta ol.tab.frame,x
	
	clc
	ldy levelCurrent.difficulty
	adc SPAWN.enemy.difficultyOffset,y
	tay
	lda SPAWN.enemy.velocityXL,y				
	sta ol.tab.velXL,x
	lda SPAWN.enemy.velocityXH,y
	sta ol.tab.velXH,x
	lda SPAWN.enemy.velocityYL,y
	sta ol.tab.velYL,x
	lda SPAWN.enemy.velocityYH,y
	sta ol.tab.velYH,x
	
skipRotation rts		
.endp


.endp	; OLP
