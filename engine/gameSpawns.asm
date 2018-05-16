;	TIMEPILOT
;	SPAWN SYSTEM 
; 	spawns: shots, enemies, squadrons, missiles, bombs, clouds, parachute, boss 
 
.proc	SPAWN
; mainLoop			spawn system - main loop
; playerShot		spawns player shots
; enemy				spawns enemies/squadrons
; enemyShots		spawns enemy shots
; enemyBombs		spawns enemy bombs
; cloudSmall		spawns small clouds/asteroids
; cloudMedium		spawns medium clouds/asteroids
; cloudBig			spawns big clouds/asteroids
; parachute			spawns parachute
; startingClouds	spawns starting clouds
; boss				spawns Boss
; explodeAll		sets all objects on screen to be exploded

.proc mainLoop
	
	jsr SPAWN.cloudBig
	jsr SPAWN.cloudSmall
	jsr SPAWN.cloudMedium

	; are we allowed to spawn common objects?
	lda levelCurrent.allowSpawns	
	beq @+
	jsr SPAWN.parachute
	jsr SPAWN.enemy		

	jsr SPAWN.enemyShots
	jsr SPAWN.enemyBombs
@	
	lda levelCurrent.explodeAll
	bne SPAWN.explodeAll
	rts
.endp

; -----------------------
;	EXPLODE ALL
;   next lvl/player died	
; -----------------------
.proc explodeAll
	ldx #(engineMaxCommon-1)
	
explode
	lda ol.tab.type+olCommon,x				; set explosion only to active objects
	beq @+
	lda #ol.type.explosion
	sta ol.tab.type+olCommon,x
	lda #0
	sta ol.tab.animationCounter+olCommon,x
@	
	dex
	bpl explode
	
	lda #ol.type.explosion					; a boss explodes on 2 objects in olCommons sublist
	sta ol.tab.type+olCommon+1
	sta ol.tab.type+olCommon+2
	lda ol.tab.posXH+olBoss
	sta ol.tab.posXH+olCommon+1
	lda ol.tab.posYH+olBoss
	sta ol.tab.posYH+olCommon+1
	sta ol.tab.posYH+olCommon+2
	clc
	lda ol.tab.posXH+olBoss
	adc #16
	sta ol.tab.posXH+olCommon+2
	
	
	lda #0									; destroy parachute, enemy shots
	sta ol.tab.type+olParachute
	sta ol.tab.type+olEnemyShots
	sta ol.tab.type+olEnemyShots+1
	
	jsr enemyFire.clear		; A = 0
	lda #1
	jsr enemyFire.clear
	
	dec levelCurrent.explodeAll	 	 
	rts

.endp


; ---------------------
;	PLAYER EXPLOSION 	
; ---------------------
.proc playerExplosion
	; spawn as first element of object lists 
	ldx #olCommon		
	lda #ol.type.explosion
	sta ol.tab.type,x
	lda #0
	sta ol.tab.animationCounter,x
	lda #120
	sta ol.tab.posXH,x
	lda #120
	sta ol.tab.posYH,x
	rts
.endp
	
; --------------------
;	SPAWN: CLOUD SMALL
; --------------------
.proc cloudSmall
	lda cloudCounter1
	cmp maxCloud1
	bcs skip
	
	lda random
	and #7
	bne skip

	
	ldx maxCloudsSpawn							; search for free space in ol.table.clouds
search	
	lda ol.tab.type+olClouds,x
	beq @+
	dex
	bpl search 	
	rts											; cannot spawn  
@
	;clc !
	inc cloudCounter1
	lda random
	and #3
	adc player.currentFrame
										
	tay		
	lda #ol.type.cloud1
	sta ol.tab.type+olClouds,x
fill	
	lda spawnPositionCloudBig.X,y				; starting position
	sta ol.tab.posXH+olClouds,x
	lda spawnPositionCloudBig.Y,y
	sta ol.tab.posYH+olClouds,x
	lda #fadeOut
	sta ol.tab.fadeOut+olClouds,x
skip
	rts
	
fadeOut	equ 16
.endp

; ---------------------
;	SPAWN: CLOUD MEDIUM
; ---------------------
.proc cloudMedium
	lda cloudCounter2
	cmp maxCloud2
	bcs skip
	
	lda random
	and #7
	bne skip

	
	ldx maxCloudsSpawn							; search for free space in ol.table.clouds
search	
	lda ol.tab.type+olClouds,x
	beq @+
	dex
	bpl search 	
skip
	rts		; cannot spawn  
@
	; C is clear
	;clc
	inc cloudCounter2
	lda random
	and #3
	adc player.currentFrame

	tay
	lda #ol.type.cloud2
	sta ol.tab.type+olClouds,x
	bne cloudSmall.fill ;!
	
fadeOut	equ 16
.endp

; -------------------
;	SPAWN: CLOUD BIG
; -------------------
.proc cloudBig
	lda cloudCounter3
	cmp maxCloud3
	bcs skip
	
	lda random
	and #7
	bne skip

	ldx maxCloudsSpawn				; search for free space in ol.table.clouds
search	
	lda ol.tab.type+olClouds,x
	beq @+
	dex
	bpl search 	
skip
	rts										; cannot spawn  
@
	;clc !
	inc cloudCounter3
	lda random
	and #3
	adc player.currentFrame
	
	tay
	lda #ol.type.cloud3
	sta ol.tab.type+olClouds,x
	bne cloudSmall.fill ;!	
	
fadeOut	equ 16
.endp

	
; -------------------
;	SPAWN: ENEMY	
; -------------------
.proc	enemy	

	lda enemyCounter
	cmp maxEnemies						; max enemies spawned?
	bcs lrts
	
spawn
	lda random							; enemy periodicity for current level/difficulty
	and levelCurrent.enemyPeriodicity
	beq doSpawn
lrts
	rts
	
doSpawn	
	lda gameCurrentLevel				; lvl 5 - no squadrons for UFO
	cmp #5
	beq singleEnemy
		
	lda squadronDelay					; checks for squadron: delay and periodicity
	beq @+ 
	dec squadronDelay
	bne singleEnemy
@	lda random
	and levelCurrent.squadronPeriodicity
	bne singleEnemy
	lda enemyCounter
	cmp maxEnemiesSquadron				; we need min. 3 free slots in enemy list to spawn squadron | maxEnemies-2
	bcs singleEnemy
										
	lda #configSquadronSpawnDelay		; squadron initialization
	sta squadronDelay

	lda player.currentFrame				; lets find squadron starting direction
	adc #2								; c is clear
	and #$f
	lsr
	lsr
	sta squadronSide
	tax
	lda squadronPosition.squadronDataL,x
	sta squadronAddr
	lda squadronPosition.squadronDataH,x
	sta squadronAddr+1
	lda #{nop}							; default direction
	sta squadronPosition.direction

	lda random
	sta squadronShake					; global position shake for squadron
	and #1
	sta squadronAlt						; 0 = alternative direction | >0 = normal direction 
	bne @+
	lda #{iny}							; alternative direction
	sta squadronPosition.direction
@	
	lda #$e
	jsr sound.soundInit.changeSong
	jsr fixBossSound
	lda #2						
	sta spawnCounter
	sta spawnType
	bne spawnUnit

singleEnemy								; single enemy
	lda #0
	sta spawnType
	sta spawnCounter

spawnUnit		
	ldx #(engineMaxCommon-1)
search	
	lda ol.tab.type+olCommon,x
	beq @+
	dex
	bpl search 	
	rts									; cannot spawn (no room in ol.tab)
@
	inc enemyCounter
	
	lda spawnType
	bne @+
	beq singleUnit						; single unit
@	
	jsr squadronPosition				; squadron unit | returns (in A) unit starting frame
	jsr skipUnitPosition
	dec spawnCounter
	bpl spawnUnit
skip	
	rts

; X - free object in ol.tab list
singleUnit
	clc
	lda random
	and #7
	adc player.currentFrame
	
	tay
	lda spawnPositionEnemy.X,y
	sta ol.tab.posXH+olCommon,x
	lda spawnPositionEnemy.Y,y
	sta ol.tab.posYH+olCommon,x
	
	lda random
	and levelCurrent.rotationDelay
	adc levelCurrent.rotationDelayMin
	asl									; starting rotation delay higher
	asl
	sta ol.tab.rotationDelay+olCommon,x
		
	lda random							; enemy starting frame
	and #3
	adc player.currentFrame
	adc #6
	and #$f
	
skipUnitPosition						; A = unit starting frame
	sta ol.tab.frame+olCommon,x
	ldy levelCurrent.difficulty
	adc difficultyOffset,y
	tay
	lda velocityXL,y				
	sta ol.tab.velXL+olCommon,x
	lda velocityXH,y
	sta ol.tab.velXH+olCommon,x
	lda velocityYL,y
	sta ol.tab.velYL+olCommon,x
	lda velocityYH,y
	sta ol.tab.velYH+olCommon,x
	
	lda random
	and levelCurrent.agilityDelay		
	adc levelCurrent.agilityMinimum
	sta ol.tab.agilityDelay+olCommon,x
	
	lda #ol.type.enemy   		
	sta ol.tab.type+olCommon,x
	lda fadeOut
	sta ol.tab.fadeOut+olCommon,x
	
	lda random
	and #1
	beq @+
	lda #{iny}
	bne direction
@
	lda #{dey}
direction	
	sta ol.tab.rotationDirection+olCommon,x
	sta ol.tab.enemyShotIsAllowed+olCommon,x		
	sta ol.tab.enemyBombIsAllowed+olCommon,x		
	lda random
	and #15
	sta ol.tab.rotationTargetFrame+olCommon,x
	rts

maxEnemies			dta b(engineMaxEnemies)
maxEnemiesSquadron	dta b(engineMaxEnemies-2)

; set position of squadron unit  	
; IN: X = object number in ol.tab
; OUT: A = unit starting frame (important!)
.proc squadronPosition

	lda squadronRotationDelay
	sta ol.tab.rotationDelay+olCommon,x

	lda spawnCounter					
	asl
	asl
	tay
	
	lda (squadronAddr),y
	sta ol.tab.posXH+olCommon,x		; X pos
	iny
	lda (squadronAddr),y
	sta ol.tab.posYH+olCommon,x		; Y pos
	
	lda squadronAlt					; no position shake if alternative direction (4 corners) 
	beq direction
	lda squadronSide
	and #1
	bne @+	
	lda squadronShake				; shakeX
	and #127
	adc ol.tab.posXH+olCommon,x		
	sta ol.tab.posXH+olCommon,x
@
	lda squadronSide
	and #1
	beq @+
	lda squadronShake				; shakeY
	and #63
	adc ol.tab.posYH+olCommon,x		
	sta ol.tab.posYH+olCommon,x
@	
	
direction	
	nop								; automodified byte:  nop or iny (nop = default direction; iny = alternative direction) 			
	iny								
	lda (squadronAddr),y			; unit starting frame
	rts

squadronRotationDelay	dta b(configSquadronRotationDelay)

squadronDataL 	dta l(squadronTop), l(squadronRight), l(squadronBottom), l(squadronLeft)
squadronDataH 	dta h(squadronTop), h(squadronRight), h(squadronBottom), h(squadronLeft)

; squadron spawn data for each screen quarter before randomization | x, y, starting frame, alternative direction starting frame
squadronXOffset		equ 8		
squadronYOffset		equ 8		
unitWidth			equ 16
unitHeight			equ 16
squadronXDistance	equ 15
squadronYDistance	equ 15

squadronTop			dta b(prScreenXMin+squadronXOffset-squadronXDistance), b(prScreenYMin-squadronYDistance-unitWidth),b(8),b(6)
					dta b(prScreenXMin+squadronXOffset), b(prScreenYMin-unitWidth), b(8),b(6)
					dta b(prScreenXMin+squadronXOffset+squadronXDistance), b(prScreenYMin-squadronYDistance-unitWidth),b(8),b(6)
				
squadronRight 		dta b(prScreenXMax+squadronXDistance),b(prScreenYMin+squadronYOffset-squadronYDistance), b(12),b(10)
					dta b(prScreenXMax),b(prScreenYMin+squadronYOffset), b(12),b(10)
					dta b(prScreenXMax+squadronXDistance),b(prScreenYMin+squadronYOffset+squadronYDistance), b(12),b(10)

squadronBottom		dta b(prScreenXMin+squadronXOffset-squadronXDistance), b(prScreenYMax+squadronYDistance), b(0),b(2)
					dta b(prScreenXMin+squadronXOffset), b(prScreenYMax), b(0),b(2)
					dta b(prScreenXMin+squadronXOffset+squadronXDistance), b(prScreenYMax+squadronYDistance), b(0),b(2)
					
squadronLeft		dta b(prScreenXMin-squadronXDistance-unitWidth),b(prScreenYMin+squadronYOffset-squadronYDistance),  b(4),b(5)
					dta b(prScreenXMin-unitWidth),b(prScreenYMin+squadronYOffset), b(4),b(5)
					dta b(prScreenXMin-squadronXDistance-unitWidth),b(prScreenYMin+squadronYOffset+squadronYDistance), b(4),b(5)
			
.endp	   
	

difficulty1			equ 700
difficulty2			equ 1100
difficulty3			equ 1400
difficulty4			equ 1800
difficultyOffset	dta b(0),b(16),b(32),b(48)
velocityXH		dta h(+$000*difficulty1/1000),h(+$90*difficulty1/1000),h(+$f4*difficulty1/1000),h(+$120*difficulty1/1000),h(+$120*difficulty1/1000),h(+$100*difficulty1/1000),h(+$100*difficulty1/1000),h(+$40*difficulty1/1000),h(+$000*difficulty1/1000),h(-$40*difficulty1/1000),h(-$100*difficulty1/1000),h(-$120*difficulty1/1000),h(-$120*difficulty1/1000),h(-$100*difficulty1/1000),h(-$100*difficulty1/1000),h(-$080*difficulty1/1000)
				dta h(+$000*difficulty2/1000),h(+$90*difficulty2/1000),h(+$f4*difficulty2/1000),h(+$120*difficulty2/1000),h(+$120*difficulty2/1000),h(+$100*difficulty2/1000),h(+$100*difficulty2/1000),h(+$40*difficulty2/1000),h(+$000*difficulty2/1000),h(-$40*difficulty2/1000),h(-$100*difficulty2/1000),h(-$120*difficulty2/1000),h(-$120*difficulty2/1000),h(-$100*difficulty2/1000),h(-$100*difficulty2/1000),h(-$080*difficulty2/1000)
				dta h(+$000*difficulty3/1000),h(+$90*difficulty3/1000),h(+$f4*difficulty3/1000),h(+$120*difficulty3/1000),h(+$120*difficulty3/1000),h(+$100*difficulty3/1000),h(+$100*difficulty3/1000),h(+$40*difficulty3/1000),h(+$000*difficulty3/1000),h(-$40*difficulty3/1000),h(-$100*difficulty3/1000),h(-$120*difficulty3/1000),h(-$120*difficulty3/1000),h(-$100*difficulty3/1000),h(-$100*difficulty3/1000),h(-$080*difficulty3/1000)					
				dta h(+$000*difficulty4/1000),h(+$90*difficulty4/1000),h(+$f4*difficulty4/1000),h(+$120*difficulty4/1000),h(+$120*difficulty4/1000),h(+$100*difficulty4/1000),h(+$100*difficulty4/1000),h(+$40*difficulty4/1000),h(+$000*difficulty4/1000),h(-$40*difficulty4/1000),h(-$100*difficulty4/1000),h(-$120*difficulty4/1000),h(-$120*difficulty4/1000),h(-$100*difficulty4/1000),h(-$100*difficulty4/1000),h(-$080*difficulty4/1000)
velocityYH		dta h(-$100*difficulty1/1000),h(-$100*difficulty1/1000),h(-$e4*difficulty1/1000),h(-$50*difficulty1/1000),h(+$000*difficulty1/1000),h(+$b0*difficulty1/1000),h(+$100*difficulty1/1000),h(+$100*difficulty1/1000),h(+$100*difficulty1/1000),h(+$100*difficulty1/1000),h(+$100*difficulty1/1000),h(+$70*difficulty1/1000),h(+$000*difficulty1/1000),h(-$c0*difficulty1/1000),h(-$100*difficulty1/1000),h(-$100*difficulty1/1000)
				dta h(-$100*difficulty2/1000),h(-$100*difficulty2/1000),h(-$e4*difficulty2/1000),h(-$50*difficulty2/1000),h(+$000*difficulty2/1000),h(+$b0*difficulty2/1000),h(+$100*difficulty2/1000),h(+$100*difficulty2/1000),h(+$100*difficulty2/1000),h(+$100*difficulty2/1000),h(+$100*difficulty2/1000),h(+$70*difficulty2/1000),h(+$000*difficulty2/1000),h(-$c0*difficulty2/1000),h(-$100*difficulty2/1000),h(-$100*difficulty2/1000)
				dta h(-$100*difficulty3/1000),h(-$100*difficulty3/1000),h(-$e4*difficulty3/1000),h(-$50*difficulty3/1000),h(+$000*difficulty3/1000),h(+$b0*difficulty3/1000),h(+$100*difficulty3/1000),h(+$100*difficulty3/1000),h(+$100*difficulty3/1000),h(+$100*difficulty3/1000),h(+$100*difficulty3/1000),h(+$70*difficulty3/1000),h(+$000*difficulty3/1000),h(-$c0*difficulty3/1000),h(-$100*difficulty3/1000),h(-$100*difficulty3/1000)
				dta h(-$100*difficulty4/1000),h(-$100*difficulty4/1000),h(-$e4*difficulty4/1000),h(-$50*difficulty4/1000),h(+$000*difficulty4/1000),h(+$b0*difficulty4/1000),h(+$100*difficulty4/1000),h(+$100*difficulty4/1000),h(+$100*difficulty4/1000),h(+$100*difficulty4/1000),h(+$100*difficulty4/1000),h(+$70*difficulty4/1000),h(+$000*difficulty4/1000),h(-$c0*difficulty4/1000),h(-$100*difficulty4/1000),h(-$100*difficulty4/1000)
				
velocityXL		dta l(+$000*difficulty1/1000),l(+$90*difficulty1/1000),l(+$f4*difficulty1/1000),l(+$120*difficulty1/1000),l(+$120*difficulty1/1000),l(+$100*difficulty1/1000),l(+$100*difficulty1/1000),l(+$40*difficulty1/1000),l(+$000*difficulty1/1000),l(-$40*difficulty1/1000),l(-$100*difficulty1/1000),l(-$120*difficulty1/1000),l(-$120*difficulty1/1000),l(-$100*difficulty1/1000),l(-$100*difficulty1/1000),l(-$080*difficulty1/1000)
				dta l(+$000*difficulty2/1000),l(+$90*difficulty2/1000),l(+$f4*difficulty2/1000),l(+$120*difficulty2/1000),l(+$120*difficulty2/1000),l(+$100*difficulty2/1000),l(+$100*difficulty2/1000),l(+$40*difficulty2/1000),l(+$000*difficulty2/1000),l(-$40*difficulty2/1000),l(-$100*difficulty2/1000),l(-$120*difficulty2/1000),l(-$120*difficulty2/1000),l(-$100*difficulty2/1000),l(-$100*difficulty2/1000),l(-$080*difficulty2/1000)
				dta l(+$000*difficulty3/1000),l(+$90*difficulty3/1000),l(+$f4*difficulty3/1000),l(+$120*difficulty3/1000),l(+$120*difficulty3/1000),l(+$100*difficulty3/1000),l(+$100*difficulty3/1000),l(+$40*difficulty3/1000),l(+$000*difficulty3/1000),l(-$40*difficulty3/1000),l(-$100*difficulty3/1000),l(-$120*difficulty3/1000),l(-$120*difficulty3/1000),l(-$100*difficulty3/1000),l(-$100*difficulty3/1000),l(-$080*difficulty3/1000)				
				dta l(+$000*difficulty4/1000),l(+$90*difficulty4/1000),l(+$f4*difficulty4/1000),l(+$120*difficulty4/1000),l(+$120*difficulty4/1000),l(+$100*difficulty4/1000),l(+$100*difficulty4/1000),l(+$40*difficulty4/1000),l(+$000*difficulty4/1000),l(-$40*difficulty4/1000),l(-$100*difficulty4/1000),l(-$120*difficulty4/1000),l(-$120*difficulty4/1000),l(-$100*difficulty4/1000),l(-$100*difficulty4/1000),l(-$080*difficulty4/1000)
velocityYL		dta l(-$100*difficulty1/1000),l(-$100*difficulty1/1000),l(-$e4*difficulty1/1000),l(-$50*difficulty1/1000),l(+$000*difficulty1/1000),l(+$b0*difficulty1/1000),l(+$100*difficulty1/1000),l(+$100*difficulty1/1000),l(+$100*difficulty1/1000),l(+$100*difficulty1/1000),l(+$100*difficulty1/1000),l(+$70*difficulty1/1000),l(+$000*difficulty1/1000),l(-$c0*difficulty1/1000),l(-$100*difficulty1/1000),l(-$100*difficulty1/1000)
				dta l(-$100*difficulty2/1000),l(-$100*difficulty2/1000),l(-$e4*difficulty2/1000),l(-$50*difficulty2/1000),l(+$000*difficulty2/1000),l(+$b0*difficulty2/1000),l(+$100*difficulty2/1000),l(+$100*difficulty2/1000),l(+$100*difficulty2/1000),l(+$100*difficulty2/1000),l(+$100*difficulty2/1000),l(+$70*difficulty2/1000),l(+$000*difficulty2/1000),l(-$c0*difficulty2/1000),l(-$100*difficulty2/1000),l(-$100*difficulty2/1000)
				dta l(-$100*difficulty3/1000),l(-$100*difficulty3/1000),l(-$e4*difficulty3/1000),l(-$50*difficulty3/1000),l(+$000*difficulty3/1000),l(+$b0*difficulty3/1000),l(+$100*difficulty3/1000),l(+$100*difficulty3/1000),l(+$100*difficulty3/1000),l(+$100*difficulty3/1000),l(+$100*difficulty3/1000),l(+$70*difficulty3/1000),l(+$000*difficulty3/1000),l(-$c0*difficulty3/1000),l(-$100*difficulty3/1000),l(-$100*difficulty3/1000)
				dta l(-$100*difficulty4/1000),l(-$100*difficulty4/1000),l(-$e4*difficulty4/1000),l(-$50*difficulty4/1000),l(+$000*difficulty4/1000),l(+$b0*difficulty4/1000),l(+$100*difficulty4/1000),l(+$100*difficulty4/1000),l(+$100*difficulty4/1000),l(+$100*difficulty4/1000),l(+$100*difficulty4/1000),l(+$70*difficulty4/1000),l(+$000*difficulty4/1000),l(-$c0*difficulty4/1000),l(-$100*difficulty4/1000),l(-$100*difficulty4/1000)

fadeOut			dta b(16)

.endp		; enemy

; ---------------------
;	SPAWN: ENEMYSHOTS
; --------------------
.proc enemyShots
	nop											; nop - normal mode | rts - swarm mode
	lda enemyShotCounter
	cmp #engimeMaxEnemyShots					; max shots spawned?
	bcs lrts	
	
spawn
	lda random
	and levelCurrent.enemyFirePeriodicity
	bne lrts
	lda #(engineMaxCommon-1)
	sta OLPCounter
searchEnemy
	ldx OLPCounter	
	lda ol.tab.type+olCommon,x  				; search for enemy plane on ol list
	cmp #ol.type.enemy	
	bne @+	
	lda ol.tab.enemyShotIsAllowed+olCommon,x	; can enemy shot?
	beq @+
	lda ol.tab.posXH+olCommon,x
	sta enemyFire.velocity.xPos
	lda ol.tab.posYH+olCommon,x
	sta enemyFire.velocity.yPos
	jsr enemyFire.velocity
	beq @+										; cant spawn enemyshot (enemy is too close to the player)
	bne doSpawn									
@
	dec OLPCounter
	bpl searchEnemy 	
lrts
	rts		

doSpawn
	ldx OLPCounter

	ldy #(engimeMaxEnemyShots-1)
searchShot	
	lda ol.tab.type+olEnemyShots,y
	beq @+
	dey
	bpl searchShot
@
	; enemy just shot - out of ammo;) [enemy can shot once per spawn]
	; A = 0
	sta ol.tab.enemyShotIsAllowed+olCommon,x
	
	lda #ol.type.fire_e
	sta ol.tab.type+olEnemyShots,y
	
	; enemy fire starts from center of the enemy
	clc
	lda ol.tab.posXH+olCommon,x
	adc #7
	sta ol.tab.posXH+olEnemyShots,y
	lda ol.tab.posYH+olCommon,x
	adc #7
	sta ol.tab.posYH+olEnemyShots,y
	
	lda enemyFire.velocity.xVel
	sta ol.tab.velXL+olEnemyShots,y
	lda enemyFire.velocity.xVel+1
	sta ol.tab.velXH+olEnemyShots,y
	lda enemyFire.velocity.yVel
	sta ol.tab.velYL+olEnemyShots,y
	lda enemyFire.velocity.yVel+1
	sta ol.tab.velYH+olEnemyShots,y
	
	; enemyshot velocity *2
	clc
	lda ol.tab.velXL+olEnemyShots,y
	adc ol.tab.velXL+olEnemyShots,y
	sta ol.tab.velXL+olEnemyShots,y
	lda ol.tab.velXH+olEnemyShots,y
	adc ol.tab.velXH+olEnemyShots,y
	sta ol.tab.velXH+olEnemyShots,y
	
	clc
	lda ol.tab.velYL+olEnemyShots,y
	adc ol.tab.velYL+olEnemyShots,y
	sta ol.tab.velYL+olEnemyShots,y
	lda ol.tab.velYH+olEnemyShots,y
	adc ol.tab.velYH+olEnemyShots,y
	sta ol.tab.velYH+olEnemyShots,y
@	
	lda player.currentFrame
	sta ol.tab.globalVelocitySpawnFrame+olEnemyShots,y
	
	inc enemyShotCounter
	
shotSoundNumber									; autocode modifications here | do not change instructions order | engine changes soundNumber and channel0/1
	ldx #soundNumber
	ldy #soundNote
	stx soundSystem.soundChannelSFX+1
	sty soundSystem.soundChannelNote+1
	rts
	
soundNumber			equ $c
soundNumberLvl5		equ $1 ; or $17
soundNote			equ 0	

.endp

; ----------------------
;	SPAWN: ENEMY BOMBS
; ----------------------
.proc enemyBombs
	nop											; nop - normal mode | rts - swarm mode
	lda enemyBombCounter						; max bombs spawned?
	cmp #engimeMaxEnemyBombs
	bcs lrts	
	
spawn
	lda random
	and levelCurrent.enemyBombPeriodicity
	bne lrts
	
@	lda #(engineMaxCommon-1)					; search spawned enemy list
	sta OLPCounter
searchEnemy
	ldx OLPCounter	
	lda ol.tab.type+olCommon,x  				; search for enemy plane
	cmp #ol.type.enemy	
	bne nextSearch
	lda ol.tab.enemyBombIsAllowed+olCommon,x	; can enemy use bombs?
	beq nextSearch
	lda ol.tab.posXH+olCommon,x
	sta enemyFire.velocity.xPos
	lda ol.tab.posYH+olCommon,x
	sta enemyFire.velocity.yPos
	jsr enemyFire.velocity
	beq nextSearch								; cant spawn enemy bomb (enemy is too close to the player)
	bne doSpawn									
nextSearch
	dec OLPCounter
	bpl searchEnemy 	
lrts
	rts		

doSpawn	
	ldy #(engineMaxCommon-1)					; search for free spot in object list
search	
	lda ol.tab.type+olCommon,y
	beq spawnBomb
	dey
	bpl search 	
	rts											; cannot spawn (no room in ol.tab)
spawnBomb
	
	ldx OLPCounter
	sta ol.tab.enemyBombIsAllowed+olCommon,x	; A=0
	lda #ol.type.bomb
	sta ol.tab.type+olCommon,y
	

	clc
	lda ol.tab.posXH+olCommon,x
	pha					
	adc #7
	sta ol.tab.posXH+olCommon,y
	lda ol.tab.posYH+olCommon,x
	adc #7
	sta ol.tab.posYH+olCommon,y
	
	pla
	cmp #prScreenXMin+(prScreenWidth/2)			; bomb direction: left or right 
	bcc @+
	lda #1
	bne side
@	lda #0	
side											
	sta ol.tab.frame+olCommon,y					; frame 0 or 1 (left/right)
	sbc #1										; positive = left | negative = right | #frame-1 = 0 or $ff						
	jsr enemyBomb.init							; init bomb velicity and acceleration
	lda #fadeOut
	sta ol.tab.fadeOut+olCommon,y

	inc enemyBombCounter
	
	lda #0										; bomb direction lvl1-4: down | lvl5: up or down | default: up
	sta ol.tab.enemyBombDirection+olCommon,y
	lda gameCurrentLevel
	cmp #5
	bne shotSoundNumber
	lda ol.tab.posYH+olCommon,x
	cmp #prScreenYMin+(prScreenHeight/2)
	bcc shotSoundNumber
	lda #1
	sta ol.tab.enemyBombDirection+olCommon,y	; ufo missile direction up
	
shotSoundNumber									; autocode modifications here | do not change instructions order | engine changes soundNumber and channel0/1
	ldx #soundNumber
	ldy #soundNote
	stx soundSystem.soundChannelSFX+1
	sty soundSystem.soundChannelNote+1
	rts
	
soundNumber			equ $a
soundNumberLvl5		equ $4
soundNote			equ 0		
		
fadeOut			equ 3
tmp dta b(0)
.endp
; -------------------
;	SPAWN: PARACHUTE	
; -------------------
.proc	parachute
	lda ol.tab.type+olParachute
	bne skip2
	
	lda parachuteSpawnDelay
	bne skip
	lda random
auto0	equ *+1	
	and #63
	bne skip2
	
	; lets spawn parachute
	lda spawnDelay
	sta parachuteSpawnDelay 
	lda #ol.type.parachute
	sta ol.tab.type+olParachute
	lda	random	
	and #127
	adc #startX
	sta ol.tab.posXH+olParachute
	lda #startY
	sta ol.tab.posYH+olParachute
	lda #fadeOut
	sta ol.tab.fadeOut+olParachute
	lda #0
	sta ol.tab.velYH+olParachute
	lda velocityYL
	sta ol.tab.velYL+olParachute
	rts
skip dec parachuteSpawnDelay	
skip2	
	rts
startX	equ prScreenXMin
startY	equ prScreenYMin-16
fadeOut	equ 24
velocityYL	dta b(64)
destroyDelay dta b(48)
spawnDelay	dta b(64)
.endp

; -------------------------------------------
;	SPAWN: BOSS
; one time per level; called in levelMainLoop	
; -------------------------------------------
.proc	boss
	lda #ol.type.boss
	sta ol.tab.type+olBoss
	lda #0
	sta ol.tab.frame+olBoss	
	lda	random	
	and #63
	adc #startY
	sta ol.tab.posYH+olBoss
	lda #startY
	sta ol.tab.posYH+olBoss
	
	lda velocityXH
	sta ol.tab.velXH+olBoss
	lda velocityXL
	sta ol.tab.velXL+olBoss
	
	ldy gameCurrentLevel
	dey
	ldx soundNumber,y
	ldy #soundNote
	stx soundSystem.soundChannelSFX+2
	sty soundSystem.soundChannelNote+2
	rts
skip dec parachuteSpawnDelay	
skip2	
	rts
soundNumber	dta b($d),b($d),b($13),b($d),b($14)	; lvl1,2,4 $d | lvl3: $13 | lvl5: $14
soundNote	equ 0	
startX	equ prScreenXMax
startY	equ prScreenYMin+16						; not used - boss starting X position is "0" on virutal screen and will start to decrease
velocityXH	dta h(-$100/2)					
velocityXL	dta l(-$100/2)
.endp

; ----------------------
;	SPAWN: PLAYER SHOT
; ----------------------
.proc playerShot
	inc playerShotCounter
	lda playerShotCounter
	and #$7
	sta playerShotCounter
	tax
	
	ldy	player.currentFrame
	
	lda #ol.type.fire_p		; type
	sta ol.tab.type,x
	
	lda #0
	sta ol.tab.posXL,x
	sta ol.tab.posYL,x
	
	lda shotStartingX,y 	; starting position
	sta ol.tab.posXH,x
	lda shotStartingY,y
	sta ol.tab.posYH,x
	
	lda velocityXL,y		; velocity
	sta ol.tab.velXL,x
	lda velocityXH,y
	sta ol.tab.velXH,x
	lda velocityYL,y
	sta ol.tab.velYL,x
	lda velocityYH,y
	sta ol.tab.velYH,x

	lda #fadeOut
	sta ol.tab.fadeOut,x
	
	ldx #soundNumber
	ldy #soundNote
	stx soundSystem.soundChannelSFX+1
	sty soundSystem.soundChannelNote+1
	rts
	
shotCounter	dta b(0)	
					;	   0	   1 	    2        3        4        5        6	     7        8        9        10       11       12       13       14       15
shotStartingX		dta b(  127),b(  132),b(  135),b(  136),b(  135),b(  135),b(  132),b(  129),b(  128),b(  124),b(  122),b(  121),b(  120),b(  121),b(  122),b(  127) ; starting X/Y position of player shot (for each player rotation frame 0-15)
shotStartingY		dta b(  120),b(  121),b(  124),b(  126),b(  128),b(  132),b(  134),b(  134),b(  135),b(  134),b(  132),b(  129),b(  128),b(  126),b(  123),b(  120) ; starting X/Y position of player shot (for each player rotation frame 0-15)
velocityXH			dta h(+$000),h(+$1a0),h(+$380),h(+$3b4),h(+$380),h(+$340),h(+$200),h(+$100),h(+$000),h(-$280),h(-$340),h(-$340),h(-$300),h(-$340),h(-$340),h(-$080) ; velocity | base max speedX: 3-3.5 
velocityYH			dta h(-$300),h(-$300),h(-$200),h(-$100),h(+$000),h(+$204),h(+$340),h(+$300),h(+$300),h(+$320),h(+$240),h(+$03c),h(+$000),h(-$1b8),h(-$220),h(-$300) ; velocity | base max speedY: 3-3.5
velocityXL			dta l(+$000),l(+$1a0),l(+$380),l(+$3b4),l(+$380),l(+$340),l(+$200),l(+$100),l(+$000),l(-$280),l(-$340),l(-$340),l(-$300),l(-$340),l(-$340),l(-$080)
velocityYL			dta l(-$300),l(-$300),l(-$200),l(-$100),l(+$000),l(+$204),l(+$340),l(+$300),l(+$300),l(+$320),l(+$240),l(+$03c),l(+$000),l(-$1b8),l(-$220),l(-$300)
fadeOut				equ 1
soundNumber			equ 2
soundNote			equ 0
.endp ; spawnPlayerShot


; -------------------------
;	SPAWNS INITIAL CLOUDS
; -------------------------
.proc	startingClouds
	ldx #0
loop
	lda random
	and #127
	adc #prScreenXMin
	adc #16
	sta ol.tab.posXH+olClouds,x
	txa
	asl
	asl
	asl
	asl
	sta tmp
	lda random
	and #15
	adc #prScreenYMin
	adc tmp
	sta ol.tab.posYH+olClouds,x
	
	lda delay,x
	sta ol.tab.movementDelay+olClouds,x
	lda clouds,x		
	sta ol.tab.type+olClouds,x
	
	; increase cloud counters
	tay
	txa
	pha
	dey
	tya
	tax	
	inc cloudCounter1,x 
	pla
	tax
		
	lda #fadeOut
	sta ol.tab.fadeOut+olClouds,x
	
	inx
	cpx maxCloudsSpawnF
	bne loop
	rts
tmp		dta b(0)
clouds	dta b(ol.type.cloud1),b(ol.type.cloud3),b(ol.type.cloud2),b(ol.type.cloud1),b(ol.type.cloud2),b(ol.type.cloud3),b(ol.type.cloud2),b(ol.type.cloud1),b(ol.type.cloud1)
delay	dta b(2),b(0),b(0),b(2),b(0),b(0),b(0),b(2),b(2)
fadeOut	equ 16
.endp

; SPAWN POSITION TABLES | depends on player ship direction
sX	equ prScreenXMin
sY	equ prScreenYMin
eX  equ prScreenXMax
eY	equ prScreenYMax
dX  equ prScreenWidth/4
dY	equ prScreenHeight/4

.local spawnPositionEnemy
cWidth  equ 16
cHeight equ 16
hWidth	equ cWidth/2
hHeight	equ cHeight/2
X		dta b(sX-cWidth),      b(sX-hWidth)  ,b(sX+dX*1-cWidth) ; 13,14,15
;						0               1                2            3             4          5			  6               7                  8                   9               10               11                   12                 13          14           15
		dta b(sX+dX*2-cWidth),b(sX+dX*3-cWidth), b(eX-cWidth), b(eX+cWidth), 	  b(eX), 	 b(eX)	 , b(eX-cWidth),  b(sX+dX*3-cWidth), b(sX+dX*2-cWidth),  b(sX+dX*1-cWidth), b(sX-cWidth),  b(sX-cWidth),      b(sX-cWidth),       b(sX-cWidth),      b(sX-hWidth)  ,b(sX+dX*1-cWidth)
		dta b(sX+dX*2-cWidth),b(sX+dX*3-cWidth), b(eX-cWidth), b(eX+cWidth) ; 0,1,2,3
		    
Y		dta b(sY+dY*1-cHeight),b(sY-cHeight) ,b(sY-cHeight) ; 13,14,15
;						0               1                2            3                 4                 5				   6               7         8             9        10               11                   12                  13                 14           15
		dta b(sY-cHeight),	  b(sY-cHeight),     b(sY-cHeight),b(sY+dY*1-cHeight),b(sY+dY*2-cHeight),b(sY+dY*3-cHeight), b(eY+cHeight), b(eY),     b(eY),      b(eY),     b(eY-cHeight), b(sY+dY*3-cHeight),b(sY+dY*2-cHeight), b(sY+dY*1-cHeight),b(sY-cHeight) ,b(sY-cHeight)
		dta b(sY-cHeight),	  b(sY-cHeight),     b(sY-cHeight),b(sY+dY*1-cHeight) ; 0,1,2,3

.endl

.local spawnPositionCloudBig
cWidth  equ 48
cHeight equ 16
hWidth	equ cWidth/2
hHeight	equ cHeight/2
X		dta b(sX-hWidth)  ,b(sX+dX*1-hWidth)   ; 14,15
;						0               1          2      3      4     5	   6          7          8            9               10          11              	  12                13                 14           15
		dta b(sX+dX*2-hWidth),b(sX+dX*3-hWidth), b(eX), b(eX), b(eX), b(eX), b(eX),  b(sX+dX*3), b(sX+dX*2),  b(sX+dX*1), b(sX-cWidth),  b(sX-cWidth),      b(sX-cWidth),       b(sX-cWidth),      b(sX-hWidth)  ,b(sX+dX*1-hWidth)
		dta b(sX+dX*2-hWidth),b(sX+dX*3-hWidth) ; 0,1
		    
Y		dta b(sY-cHeight) ,b(sY-cHeight) ; 14,15
;						0               1                2            3                 4                 5				   6               7          8         9           10               11                   12                  13                 14           15
		dta b(sY-cHeight),	  b(sY-cHeight),     b(sY-hHeight),b(sY+dY*1-cHeight),b(sY+dY*2-cHeight),b(sY+dY*3-cHeight), b(eY-hHeight), b(eY),     b(eY),      b(eY),     b(eY-cHeight), b(sY+dY*3-cHeight),b(sY+dY*2-cHeight), b(sY+dY*1-cHeight),b(sY-cHeight) ,b(sY-cHeight)
		dta b(sY-cHeight),	  b(sY-cHeight)      ; 0,1
.endl

.local spawnPositionCloudSmall
cWidth  equ 16
cHeight equ 8
.endl

.local spawnPositionCloudMedium
cWidth  equ 32
cHeight equ 16
.endl

maxCloudsSpawnF 	dta b(engineMaxCloudsSpawnF)			
maxCloudsSpawnFol 	dta b(engineMaxCloudsSpawnF+olClouds)	
maxCloudsSpawn 		dta b(engineMaxCloudsSpawn-1)			
maxCloud1			dta b(engineMaxCloud1)
maxCloud2			dta b(engineMaxCloud2)
maxCloud3			dta b(engineMaxCloud3)
globalSpawnDelay	dta b(configGlobalSpawnDelay)	
.endp ; SPAWN