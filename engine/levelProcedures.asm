; TIMEPILOT
; Level Procedures

.proc	level
; init				- inits level ; X = level number
; mainLoop			- main level loop			
; killEnemy			- progress bar			
; nextLevelPrepare	- preparation for next level
; nextLevelTeleport	- teleport
; nextLevel			- sets all needed stuff for next level

; ---------------------------------------------
;	LEVEL MAIN LOOP - jump here every gameLoop
; ---------------------------------------------

.proc mainLoop

	lda playerGameOver
	beq playLevel
	
	; gameover delay -> title screen
	dec playerGameOver
	bne @+
	jmp main
@
	rts
	
playLevel
	; allow spawns counter	

	lda levelCurrent.allowSpawnsDelay
	beq @+
	dec levelCurrent.allowSpawnsDelay
	bne @+
	inc levelCurrent.allowSpawns  ;  0 -> 1
	
	lda #0
	sta ntsc_counter
	
	; dli mode for level gameplay | setup once after spawns are allowed
	jsr waitFrameNormal
	jsr clearLevelName
	lda #<bufDLIJumps 
	sta DLIDispatch.mode+1
	jsr initPlayfieldPMColors		  
	jsr showPlayer
@
	
	; is player alive?
	lda playerDestroyed
	beq playerNotDestroyed
	lda playerDestroyedInit	
	bne @+
	
	inc playerDestroyedInit
	jsr hidePlayer
	lda #configMusicPlayerDestroyed
	jsr sound.soundInit.changeSong
@	
	dec playerDestroyedDelay
	bne playerNotDestroyed
	dec levelCurrent.allowSpawns
	lda #255
	sta levelCurrent.allowSpawnsDelay
	
	dec playerLives
	bne @+
	lda #1
	sta levelCurrent.allowSpawnsDelay
	lda #configGameOverDelay
	sta playerGameOver
	
	; INIT GAME OVER / HIGH SCORE
	jsr waitFrameNormal
	jsr SCORE.findHighScore			; returns line position in X
	beq noHiScore
	jsr SCORE.highScoreInit			; and we use line poistion here
noHiScore
	lda #0
	sta counterDLI
	sta titleScreen.screenMode
	lda #<bufDLIJumpsGameOver 
	sta DLIDispatch.mode+1
	jmp level.showGameOver
@	
	jmp level.init.levelReset
	
playerNotDestroyed
	; next level?
	lda levelCurrent.bossKilled
	bne nextLevelLoop	
	rts
	
nextLevelLoop	
	lda playerDestroyed
	beq @+
	rts							; if player is destroyed we do not initiate next level
@	
	lda level.nextLevelInited
	bne @+
	jmp level.nextLevelPrepare
@	jmp level.nextLevelTeleport
.endp
; --- END OF level.mainloop

; ---------------------
;	NEXT LEVEL PREPARE
; --------------------

nextLevelPrepare
	inc nextLevelInited 
	
	lda #0
	sta levelCurrent.allowSpawnsDelay
	sta levelCurrent.allowSpawns
	inc levelCurrent.clearedLevels
	inc levelCurrent.explodeAll
	lda #0
	sta firstRun
	jsr waitFrameNormal
	lda #configMusicTeleport
	jmp sound.soundInit.changeSong
nextLevelInited	dta b(0)
 
; ---------------------
;	NEXT LEVEL TELEPORT
; X = level number
; ---------------------

.proc nextLevelTeleport

	lda RMT.trackn_idx		; synchronize teleport main animation with RMT subsong
	cmp #101
	bcs @+
	rts
	
	lda #0
	sta ol.tab.type+olClouds
	sta ol.tab.type+olClouds+1
	sta ol.tab.type+olClouds+2
	sta ol.tab.type+olClouds+3
	sta ol.tab.type+olClouds+4
	
	; clear enemyMissiles
  	jsr enemyFire.clear		; A = 0
  	lda #1
  	jsr enemyFire.clear
	
	
@	; teleports starts here
	jsr waitFrameNormal
	jsr clearBufScreenSimple	
	lda #1
	sta bufScreenNr
	jsr clearBufFontsHidden
	jsr commitBufScreen
	
	jsr resetPlayerMask
	lda #1
	sta playerframeDraw
	jsr drawPlayer
	
	lda #0
	sta playerMovementAllow
	
	lda #$f
	sta DLI0.c3+1
	
	ldx 3
; fonts for teleport animation	
	ldx #0
@	lda fnt,x
	sta bufFonts0a+$380,x
	sta bufFonts1a+$380,x
	sta bufFonts2a+$380,x
	sta bufFonts3a+$380,x
	inx
	cpx #16*8
	bne @-
	
	; resets draw position
	ldx #0
@	lda #19
	sta x1,x
	lda #20
	sta x2,x
	inx
	cpx #charCount
	bne @-
	lda #20
	sta x1+7
	lda #19
	sta x2+7
	
	; resets delays
	lda #2
	sta delay
	lda #13
	sta delay+1
	lda #19
	sta delay+2
	lda #22
	sta delay+3
	lda #23
	sta delay+4
	lda #24
	sta delay+5
	lda #25
	sta delay+6
	lda #26
	sta delay+7
	
teleportLoop
	ldx #0
teleportIteration
	lda delay,x
	beq drawIt
	dec delay,x
	jmp next
drawIt	
	lda x1,x
	tay
	lda ch1,x
	sta bufScreen0+5*40,y
	lda ch2,x
	sta bufScreen0+6*40,y
	
	lda x2,x
	tay
	lda ch1,x
	sta bufScreen0+5*40,y
	lda ch2,x
	sta bufScreen0+6*40,y
	
	lda x1,x
	cmp m1,x
	beq @+
	dec x1,x
@	lda x2,x
	cmp m2,x
	beq next
	inc x2,x

next	
	inx
	cpx #charCount
	bne teleportIteration

doDelay	
	dec frameDelay
	beq nextLoop
	jsr waitFrameNormal

 	jsr teleportBlink
 	
	jsr drawPlayer
	lda frameDelay
	and #1
	bne @+
	jsr initPlayfieldPMColors
	jmp doDelay
@
	lda #$f
	jsr initPlayfieldPMColorsWhite
	jmp doDelay
	
nextLoop
	lda #configTeleportAnimationDelay
	sta frameDelay
	
	lda x1+7
	cmp #19 		; finished last char? do fadeout
	beq teleportFadeOut
	jmp teleportLoop

teleportFadeOut
	lda #0
	sta teleportLineOutX1
	lda #39
	sta teleportLineOutX2
teleportFadeOutLoop1
	lda #0
	sta teleportOutX1
	lda #39
	sta teleportOutX2
teleportFadeOutLoop2
	ldx teleportOutX1
	lda bufScreen0+5*40,x
	beq @+
	cmp #$f0
	beq @+
	dec bufScreen0+5*40,x
@
	lda bufScreen0+6*40,x
	beq @+
	cmp #$f8
	beq @+
	dec bufScreen0+6*40,x	

@	ldx teleportOutX2
	lda bufScreen0+5*40,x
	beq @+
	cmp #$f0
	beq @+
	dec bufScreen0+5*40,x
@	
	lda bufScreen0+6*40,x
	beq @+
	cmp #$f8
	beq @+
	dec bufScreen0+6*40,x
		
@	lda teleportOutX1
	cmp #19
	beq @+
	inc teleportOutX1
	dec teleportOutX2 
	jmp teleportFadeOutLoop2
@	
	jsr waitFrameNormal
	jsr teleportBlink
	jsr teleportLineOut
	jsr waitFrameNormal
	jsr teleportLineOut
	jsr teleportBlink			
	lda RMT.nt					; for now | find where is song line number | ;!##TRACE "ns: %d nt: %d" db(RMT.ns) db(RMT.nt)
	cmp #62			
	beq @+
	jmp teleportFadeOutLoop1

@		
	jmp level.nextLevel

teleportLineOut
	lda #0
	ldx teleportLineOutX1
	sta bufScreen0+5*40,x
	sta bufScreen0+6*40,x
	ldx teleportLineOutX2
	sta bufScreen0+5*40,x
	sta bufScreen0+6*40,x
	
	lda teleportLineOutX1
	cmp #19
	beq @+
	inc teleportLineOutX1
	dec teleportLineOutX2 
@	
	rts
teleportOutX1		dta b(0)
teleportOutX2 		dta b(0)
teleportLineOutX1 	dta b(0)
teleportLineOutX2 	dta b(0)
  

teleportBlink
	lda teleportBlinkMode
	eor #1
	sta teleportBlinkMode
	bne @+
	lda #$c
	sta DLI0.c3+1
	jmp blinkEnds
@	lda #$f
	sta DLI0.c3+1
blinkEnds	
	rts
	
charCount		equ 8		; chars used in animation (per line; 2 lines)
x1	dta b(19),b(19),b(19),b(19),b(19),b(19),b(19),b(20)
m1	dta b(0),b(5),b(10),b(14),b(16),b(17),b(18),b(19)
x2	dta b(20),b(20),b(20),b(20),b(20),b(20),b(20),b(20)
m2	dta b(39),b(34),b(29),b(25),b(23),b(22),b(21),b(20)
ch1  dta b($f0),b($f1),b($f2),b($f3),b($f4),b($f5),b($f6),b($f7)
ch2  dta b($f8),b($f9),b($fa),b($fb),b($fc),b($fd),b($fe),b($ff)
delay dta b(5),b(20),b(25),b(25),b(26),b(27),b(28),b(29)
frameDelay 			dta b(configTeleportAnimationDelay)
teleportDelay 		dta b($ff)
teleportBlinkMode 	dta b(0)

fnt .he 00 00 00 00 00 00 00 ff 
	.he 00 00 00 00 00 00 ff ff
	.he 00 00 00 00 00 ff ff ff
	.he 00 00 00 00 ff ff ff ff
	.he 00 00 00 ff ff ff ff ff
	.he 00 00 ff ff ff ff ff ff
	.he 00 ff ff ff ff ff ff ff
	.he ff ff ff ff ff ff ff ff
	.he ff 00 00 00 00 00 00 00
	.he ff ff 00 00 00 00 00 00
	.he ff ff ff 00 00 00 00 00
	.he ff ff ff ff 00 00 00 00
	.he ff ff ff ff ff 00 00 00
	.he ff ff ff ff ff ff 00 00
	.he ff ff ff ff ff ff ff 00
	.he ff ff ff ff ff ff ff ff
.endp
	
; ----------------
;	NEXT LEVEL
; X = level number
; ----------------

.proc nextLevel
	
	jsr hidePlayer
	jsr initPlayfieldPMColors
	lda #0
	sta level.nextLevelInited

	lda #configGameMaxDifficulty				; set max difficulty - stage 15+
	sta levelCurrent.difficulty
	ldy levelCurrent.clearedLevels
	cpy #15
	bcs mode
	lda levelInformation.levelDifficulty,y		; or lower difficulty for stages 1-14 | it will reset after 255 stages (a gift;)
	sta levelCurrent.difficulty
mode										
	lda levelCurrent.swarmMode					; swarm mode higher difficulty
	beq finish
	lda gameCurrentLevel
	cmp #3
	bne @+
	lda #2										; swarm mode lvl 4 different (bit slower; only UFO difficulty is fully maxed)
	sta levelCurrent.difficulty
	bne finish
@	
	lda levelInformation.levelDifficulty,y
	tax
	inx
	cpx #configGameMaxDifficulty+1
	bcc @+
	ldx #configGameMaxDifficulty
@	
	stx levelCurrent.difficulty
finish	
	inc gameCurrentLevel						; levels 1-5 then new loop
	lda gameCurrentLevel
	cmp #configGameMaxLevel+1
	bne @+
	lda #1
	sta gameCurrentLevel
@	
	jsr waitFrameNormal
	ldx gameCurrentLevel
	jsr level.init
	jmp initPlayfieldPM	

.endp
	
; ----------------
;	INIT LEVEL
; X = level number
; ----------------	 	
.proc init	 
		dex
		stx levelNumber
		txa
		asl
		asl
		tax

		jsr waitFrameNormal		
; progress bar colors			
		lda levelInformation.levelBarColor,x
		sta DLI4.c0+1
		sta DLI4b.c0+1
		lda levelInformation.levelBarColor+1,x
		sta DLI4.c1+1
		sta DLI4b.c1+1
		lda levelInformation.levelBarColor+2,x
		sta DLI4.c2+1
		sta DLI4b.c2+1

; playfield colors
		lda levelInformation.levelPlayfieldColor,x
		sta DLI0.c0+1
		lda levelInformation.levelPlayfieldColor+1,x
		sta DLI0.c1+1
		lda levelInformation.levelPlayfieldColor+2,x
		sta DLI0.c2+1
		lda levelInformation.levelPlayfieldColor+3,x
		sta DLI0.c3+1
		ldx levelNumber
		lda levelInformation.levelBackgroundColor,x
		sta DLI0.c4+1
		
;	progress bar seeder		
		ldx levelNumber
		txa
		asl @
		tax
		lda levelInformation.levelBarTile,x
		sta barFrom+1
		lda levelInformation.levelBarTile+1,x
		sta barFrom+2
		lda #<bufProgressBar
		sta barTo+1
		lda #>bufProgressBar
		sta barTo+2
		
		lda #8
		sta counter
startY	ldy #0
startX	ldx #0
barFrom lda $ffff,x
barTo	sta $ffff,y
		iny
		inx
		cpx #4
		bne barFrom
		ldx #0
		cpy #4*7	; 7 tiles
		bne startX
		
		adw barFrom+1 #4
		adw barTo+1 #40
@		
		dec counter
		bne startY

		ldx levelNumber
		lda levelInformation.levelToKill,x
		sta levelCurrent.tokill
		lda levelInformation.levelEnemyBossHP,x
		sta levelCurrent.enemyBossHP
		lsr @
		sta levelCurrent.enemyBossHalfHP
		
	
skipPreInit
		lda #0
		sta levelCurrent.bossKilled
		sta levelFullyInited

		; LVL1-4 and LVL5 differences | enemyShot sound lvl1-4 and lvl5 |  clouds lvl1-4, asteroids lvl5 | X=4 for lvl5
		cpx #4  		 
		bne @+
		jsr prPreinitLvl5							; asteroids
		lda #SPAWN.enemyShots.soundNumberLvl5
		sta SPAWN.enemyShots.shotSoundNumber+1
		lda #SPAWN.enemyBombs.soundNumberLvl5	
		sta SPAWN.enemyBombs.shotSoundNumber+1
		bne shotSoundSetDone		
@		lda firstRun
		bne @+
		cpx #0
		bne @+
		jsr prPreinitLvl1							; clouds
@		lda #SPAWN.enemyShots.soundNumber
		sta SPAWN.enemyShots.shotSoundNumber+1
		lda #SPAWN.enemyBombs.soundNumber
		sta SPAWN.enemyBombs.shotSoundNumber+1
shotSoundSetDone		

levelReset
		
		; enemy shots on channel0 (during subsongs we move it temporaly to channel1)
		lda <soundSystem.soundChannelSFX
		sta SPAWN.enemyShots.shotSoundNumber+5
		sta SPAWN.enemyBombs.shotSoundNumber+5
		
		lda #4											; player's starting position (ship flying right = 4) 
		sta player.currentFrame
							
		ldx levelNumber
		lda levelInformation.levelRotationDelayMin,x
		sta levelCurrent.rotationDelayMin
		lda levelInformation.levelAgilityDelay,x
		sta levelCurrent.agilityDelay
		lda levelInformation.levelAgilityMinimum,x
		sta levelCurrent.agilityMinimum
		lda levelInformation.levelAllowSpawnsDelay,x
		sta levelCurrent.allowSpawnsDelay
		lda levelInformation.levelEnemyPeriodicity,x
		sta levelCurrent.enemyPeriodicity
		lda levelInformation.levelEnemyFirePeriodicity,x
		sta levelCurrent.enemyFirePeriodicity
		lda levelInformation.levelSquadronPeriodicity,x
		sta levelCurrent.squadronPeriodicity
		lda levelInformation.levelEnemyBombPeriodicity,x
		sta levelCurrent.enemyBombPeriodicity
		
		lda #configSquadronSpawnDelay
		sta squadronDelay
		
		; during level reset (but not on first run) we decrease global allowSpawnsDelay
		lda levelFullyInited
		beq @+
		lda #15
		sta levelCurrent.allowSpawnsDelay			
@		
	
		cpx #4 ; (level 5 has different enemyShot shape)
		beq lvl5
		lda #$ff
		sta enemyFire.mask
		sta enemyFire.mask+1
		sta enemyFire.mask+2
		bne @+
lvl5	lda #%1011010
		sta enemyFire.mask
		lda #%10100101
		sta enemyFire.mask+1
		lda #%01011010
		sta enemyFire.mask+2
@
		
		lda #1						
		sta playerMovementAllow
		
		lda #configPlayerShotMaxChain
		sta playerShotChain

		jsr waitFrameNormal
		jsr clearBufFontsHidden
		
  		jsr prPrepareGfxCommonInit
  		ldx levelNumber
  		inx
		jsr prPrepareGfxCommon		; enemies 1-5 (X = level number)

		ldx levelNumber
		inx
		jsr prPrepareGfxBoss
		
		lda #0
		sta frameCounter
		sta OLPCounter			
		sta playerShotCounter	
		sta enemyCounter	
		sta enemyShotCounter
		sta enemyBombCounter
		sta levelCurrent.explodeAll
		sta parachuteDestroyDelay
		sta cloudCounter1
		sta cloudCounter2
		sta cloudCounter3
		sta levelCurrent.allowSpawns
		sta playerDestroyed
		sta playerDestroyedInit	
		sta level.nextLevelInited
		jsr enemyFire.hitClear		; A = 0

		lda #80
		sta playerDestroyedDelay
		
		lda #configAnimationSwitchDelay
		sta animationSwitchCounter
		
		lda SPAWN.parachute.spawnDelay
		sta parachuteSpawnDelay
	
  		jsr OLP.init
  		
  		; clear enemyMissiles
  		lda #0  		
  		jsr enemyFire.clear
  		lda #1
  		jsr enemyFire.clear
  		
		jsr spawn.startingClouds
		
		; DLI for level start
		lda levelFullyInited
		bne skipLevelName
		jsr waitFrameNormal
		lda #0
		sta counterDLI
		lda #<bufDLIJumpsLevelStart
		sta DLIDispatch.mode+1
		jsr level.showLevelName
skipLevelName
		
		; was boss spawned? if so - re-respawn it
		lda levelCurrent.toKill
		bne @+
		lda levelCurrent.bossKilled
		bne @+
		jsr SPAWN.boss
@		
		jsr level.showPlayerLives
		
		lda #1
		sta levelFullyInited
		
		lda ntsc
		sta ntsc_counter
		
		jmp showPlayer
		
; local data for routines	
counter		dta b(0)
levelNumber	dta b(0)

.endp		
; ---- end of INIT LEVEL ---- ;
		
; ----------------
; SHOW LEVEL NAME
; ----------------
.proc showlevelName
	ldx #7
@	
	; A.D.
	lda dataTextFonts+$21*8,x
	sta bufPM0+31,x
	lda dataTextFonts+$e*8,x
	sta bufPM1+31,x
	lda dataTextFonts+$24*8,x
	sta bufPM2+31,x
	lda dataTextFonts+$e*8,x
	sta bufPM3+31,x
	dex
	bpl @-
	
	; Y E A R
	ldx gameCurrentLevel
	dex
	txa 
	asl
	asl
	tax
	lda levelYearL,x
	sta a1+1
	lda levelYearH,x
	sta a1+2
	lda levelYearL+1,x
	sta a2+1
	lda levelYearH+1,x
	sta a2+2
	lda levelYearL+2,x
	sta a3+1
	lda levelYearH+2,x
	sta a3+2
	lda levelYearL+3,x
	sta a4+1
	lda levelYearH+3,x
	sta a4+2
	
	ldx #7
a1	lda $ffff,x			
	sta bufPM0+88,x
a2	lda $ffff,x	
	sta bufPM1+88,x
a3	lda $ffff,x
	sta bufPM2+88,x
a4	lda $ffff,x
	sta bufPM3+88,x
	dex
	bpl a1
	rts

levelYearL dta l(dataTextFonts+$11*8),l(dataTextFonts+$19*8),l(dataTextFonts+$11*8),l(dataTextFonts+$10*8)
		   dta l(dataTextFonts+$11*8),l(dataTextFonts+$19*8),l(dataTextFonts+$14*8),l(dataTextFonts+$10*8)
		   dta l(dataTextFonts+$11*8),l(dataTextFonts+$19*8),l(dataTextFonts+$17*8),l(dataTextFonts+$10*8)
		   dta l(dataTextFonts+$11*8),l(dataTextFonts+$19*8),l(dataTextFonts+$18*8),l(dataTextFonts+$12*8)
		   dta l(dataTextFonts+$12*8),l(dataTextFonts+$10*8),l(dataTextFonts+$17*8),l(dataTextFonts+$17*8)
levelYearH dta h(dataTextFonts+$11*8),h(dataTextFonts+$19*8),h(dataTextFonts+$11*8),h(dataTextFonts+$10*8)
		   dta h(dataTextFonts+$11*8),h(dataTextFonts+$19*8),h(dataTextFonts+$14*8),h(dataTextFonts+$10*8)
		   dta h(dataTextFonts+$11*8),h(dataTextFonts+$19*8),h(dataTextFonts+$17*8),h(dataTextFonts+$10*8)
		   dta h(dataTextFonts+$11*8),h(dataTextFonts+$19*8),h(dataTextFonts+$18*8),h(dataTextFonts+$12*8)
		   dta h(dataTextFonts+$12*8),h(dataTextFonts+$10*8),h(dataTextFonts+$17*8),h(dataTextFonts+$17*8)


.endp	
; ---- end of SHOW LEVEL NAME ---- ;

; show GAME OVER
.proc showGameOver
	ldx #7
@	; GAME
	lda dataTextFonts+$27*8,x
	sta bufPM0+31,x
	lda dataTextFonts+$21*8,x
	sta bufPM1+31,x
	lda dataTextFonts+$2d*8,x
	sta bufPM2+31,x
	lda dataTextFonts+$25*8,x
	sta bufPM3+31,x
	;  OVER
	lda dataTextFonts+$2f*8,x
	sta bufPM0+88,x
	lda dataTextFonts+$36*8,x
	sta bufPM1+88,x
	lda dataTextFonts+$25*8,x
	sta bufPM2+88,x
	lda dataTextFonts+$32*8,x
	sta bufPM3+88,x
	dex
	bpl @-
	rts
.endp

; ----------------
; CLEAR LEVEL NAME
; ----------------
.proc	clearLevelName
	ldx #7
	lda #0
@	
	sta bufPM0+31,x
	sta bufPM1+31,x
	sta bufPM2+31,x
	sta bufPM3+31,x
	sta bufPM0+88,x
	sta bufPM1+88,x
	sta bufPM2+88,x
	sta bufPM3+88,x
	dex
	bpl @-
	rts 
.endp			


; -----------------
; SHOW PLAYER LIVES
;  on level reset
; -----------------
.proc showPlayerLives

		lda #<bufProgressBar
		sta clear1+1
		lda #>bufProgressBar
		sta clear1+2
		adw clear1+1 #30
		ldy #7
clrs	ldx #9
clr0	lda #0
clear1	sta $ffff,x
		dex
		bpl clr0
		adw clear1+1 #40
		dey
		bpl clrs
		
		ldx playerLives
		cpx #2
		bcs @+
		rts
@		
		dex
		dex
		txa
		cmp #4
		bcs max4
		sta lives
		jmp start
max4	lda #4
		sta lives		
start		
		lda <livesGFX
		sta barFrom+1
		lda >livesGFX
		sta barFrom+2
		lda #<bufProgressBar
		sta barTo+1
		lda #>bufProgressBar
		sta barTo+2
		
		adw barTo+1 #38
		
		lda lives
		asl 
		sta tmp
		sbw barTo+1 tmp
		
		lda #8
		sta counter
startY	ldy #0
startX	ldx #0
barFrom lda $ffff,x
barTo	sta $ffff,y
		iny
		inx
		cpx #2
		bne barFrom
		ldx #0
		cpy #2*1	; 1 tile
		bne startX
		adw barFrom+1 #2
		adw barTo+1 #40
@		
		dec counter
		bne startY
		
		dec lives
		bpl start	
		rts

livesGFX  .he 00 80 00 80 02 60 12 61 1a 69 2a aa 22 a2 10 81
lives 	dta b(0)
tmp		dta b(0)
counter dta b(0)
.endp

; ----------------
;	KILL ENEMY
; X = enemy number
; ----------------		
.proc killEnemy
	lda levelCurrent.tokill
	beq @+
	dec levelCurrent.tokill		
	dec levelCurrent.tokill
	bne decreaseProgressBar
	jsr SPAWN.boss		; all enemy for this level killed - spawn boss
	jmp decreaseProgressBar
@						
	rts

decreaseProgressBar
	lda levelCurrent.tokill
	pha
	lsr @
	tax
	pla
	and #1
	bne @+
	.rept 8
	progressBarRight .R
	.endr
@
	.rept 8
	progressBarLeft .R
	.endr
progressDone
	rts
		
.macro progressBarRight 
	lda bufProgressBar+$000+(:1*40),x
	and #%00001111
	sta bufProgressBar+$000+(:1*40),x
.endm
	
.macro progressBarLeft 
	lda bufProgressBar+$000+(:1*40),x
	and #%11110000
	sta bufProgressBar+$000+(:1*40),x
.endm
.endp
; ---- end of KILL ENEMY ---- ;
		
			
.endp	

.local levelInformation
levelBarTile		dta a(dataProgressBar1),a(dataProgressBar2),a(dataProgressBar3),a(dataProgressBar4),a(dataProgressBar5)	; 16x8 graphic tile
levelBarColor		dta b($84),b($9a),b($fa),b(0) 		; level 1
					dta b($84),b($9a),b($fa),b(0) 		; level 2
					dta b($84),b($9a),b($fa),b(0) 		; level 3
					dta b($84),b($9a),b($fa),b(0) 		; level 4
					dta b($9a),b($84),b($fa),b(0) 		; level 5

levelPlayfieldColor	dta b($ea),b($24),b($d6),b($f)		; level 1
					dta b($c8),b($c6),b($36),b($f) 		; level 2
					dta b($ea),b($34),b($8a),b($f) 		; level 3
					dta b($ff),b($84),b($8a),b($f) 		; level 4
					dta b($84),b($9c),b($ff),b($f) 		; level 5

levelBackgroundColor		dta b($80),b($84),b($94),b($42),b($0)
levelToKill					dta b(56),b(56),b(56),b(56),b(56)		; 112 progress bar pixels / 2 | 56 default
levelEnemyBossHP			dta b(14),b(16),b(18),b(20),b(24)

; stock CPU
levelRotationDelayMin		dta b(7),b(7),b(5),b(5),b(4)			; minimum delay for rotation (used if rotation is in progress) 
levelRotationDelay			dta b(15),b(7),b(7),b(7),b(7)			; 'and' mask for rotation delay randomization (we add rnd to levelRotationDelayMin)
levelAllowSpawnsDelay		dta b(60),b(60),b(60),b(60),b(60)		; delay before we can spawn anything in level (during that time we see level name)
levelAgilityDelay			dta b(15),b(15),b(7),b(7),b(3)			; 'and' mask for agility randomization (delay before init new enemy rotation)  
levelAgilityMinimum			dta b(15),b(9),b(7),b(4),b(3)			; minimum agility per level
levelEnemyPeriodicity		dta b(15),b(7),b(3),b(3),b(1)			; 'and' mask for random (lover mask - better periodicity)
levelSquadronPeriodicity	dta b(1),b(1),b(1),b(1),b(1)			; 'and' mask for random (lover mask - better periodicity)					
levelEnemyFirePeriodicity	dta b(31),b(15),b(15),b(7),b(3)			; 'and' mask for random (lover mask - better periodicity)
levelEnemyBombPeriodicity	dta b(31),b(31),b(15),b(7),b(1)			; 'and' mask for random (lover mask - better periodicity)

; rapidus CPU
rapidusLevelRotationDelayMin		dta b(14),b(14),b(10),b(10),b(8)			
rapidusLevelRotationDelay			dta b(31),b(15),b(15),b(15),b(15)
rapidusLevelAllowSpawnsDelay		dta b(120),b(120),b(120),b(120),b(120)					
rapidusLevelAgilityDelay			dta b(31),b(31),b(15),b(15),b(7)			
rapidusLevelAgilityMinimum			dta b(30),b(18),b(14),b(8),b(6)			
rapidusLevelEnemyPeriodicity		dta b(31),b(15),b(7),b(7),b(3)
rapidusLevelSquadronPeriodicity		dta b(3),b(3),b(3),b(3),b(3)						
rapidusLevelEnemyFirePeriodicity	dta b(63),b(31),b(31),b(15),b(7)			
rapidusLevelEnemyBombPeriodicity	dta b(63),b(63),b(31),b(15),b(3)			
		
; secondary (independent) difficulty for lvls 1-5 (stages 1-14); from stage 15 - difficulty is always set to #configGameMaxDifficulty	
levelDifficulty  	dta b(0,0,1,2,3)	  
					dta b(1,2,2,3,3)
					dta b(2,2,3,3,3)		 
.endl

