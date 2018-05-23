; ----------------
; 	TimePilot
;  memory LAYOUT
; ----------------

; ***** ZERO PAGE *****

;global page zero variables goes here
zeroPage	equ $00
counterDLI	equ zeroPage

gameCurrentLevel		equ zeroPage+2 ; 1 byte
playerShotChain			equ zeroPage+3 ; 1 byte 	
frameCounter			equ zeroPage+4	; frame counter (how many frames per rendered scene) 
playerShotDelay			equ zeroPage+5	; 1 byte delay beetwen shots
playerShotChannel		equ zeropage+6	; [NOT USED ANYMORE] was for: 1 byte pokey channel for fire (2 or 3)
playerFrameDraw			equ zeroPage+7	; 1 byte flag if we have to draw new player frame
.local player
	animationDelay	equ zeroPage+8	; delay counter before we go to next player animation frame
	currentFrame	equ	zeroPage+10	; current player frame
	lastFrame		equ zeroPage+11	; playe frame before	
.endl
gamePaused				equ zeropage+12 ; 1 byte    0 - game is running | 1 - game is paused
gamePauseDelay			equ zeropage+13 ; 1 byte    delay before we can unpause/pause the game
gameSFXAllow			equ zeroPage+14 ; 1 byte	[NOT USED ANYMORE]
playerMovementAllow		equ zeroPage+15 ; 1 byte	
bufScreenNr				equ zeroPage+16 ; 1 byte | high byte of screen address
OLPCounter				equ zeroPage+17 ; 1 byte | temporal counter for object list (OLP) used in various logic
playerShotCounter		equ zeroPage+18 ; 1 byte | active player shots - used in OLP (so we dont have to check the list)
enemyCounter			equ zeroPage+19 ; 1 byte | active enemies - used in OLP (so we dont have to check the list)
enemyShotCounter		equ zeroPage+20 ; 1 byte | active enemy shots - used in OLP (so we dont have to check the list)
animationSwitch			equ zeroPage+21 ; 1 byte | switches global animation per gameLoop (0-1)
animationSwitchCounter  equ zeroPage+22 ; 1 byte | delay for animationSwitch; can be setup in config 
cloudCounter1			equ zeroPage+23 ; 1 byte
cloudCounter2			equ zeroPage+24 ; 1 byte
cloudCounter3			equ zeroPage+25 ; 1 byte
parachuteSpawnDelay		equ zeroPage+26 ; 1 byte
parachuteDestroyDelay	equ zeroPage+27 ; 1 byte
playerMaskTouched		equ zeroPage+28 ; 1 byte 1 if player mask has been touched
playerDestroyed			equ zeroPage+29 ; 1 byte 1 if player is destroyed
playerDestroyedDelay	equ zeroPage+30 ; 1 byte - delay1 before we reset level after death
playerDestroyedInit		equ zeroPage+31 ; 1 byte - is destroy delay inited? 
playerLives				equ zeroPage+32 ; 1 byte 
playerScore				equ zeroPage+33 ; 2 bytes
hiScore					equ zeroPage+35 ; 2 bytes
hiScoreNew				equ zeroPage+37 ; 1 byte 0/1 flag if player got new higscore (so we rewrite it on screen)
levelFullyInited		equ zeroPage+38 ; 1 byte
playerGameOver			equ zeroPage+39 ; 1 byte 0/1 flag
extraLifeScore			equ zeroPage+40 ; 2 bytes	
extraLifeValue			equ zeroPage+42 ; 1 byte  	amount of score we add an extralife | 1 = 10.000, 5 = 50.000
extraLifeDuration		equ zeroPage+43 ; 1 byte  	during extra life subsong we swap SFX channels for enemy shots for a duration 
firstRun				equ	zeroPage+44 ; 1 byte	0/1 flag (first game run; resets at title screen) 
spawnCounter			equ zeroPage+45	; 1 byte	how many units to spawn in enemy spawn routine
spawnType				equ zeroPage+46	; 1 byte	single unit or squadron
squadronDelay			equ zeropage+47	; 1 byte	min. delay (in 'spawned units') before next squadron can be randomly spawned
squadronSide			equ zeropage+48	; 1 byte	screen side for squadron (top,right,bottom,left) | values 0-3
squadronShake			equ zeropage+49 ; 1 byte 	randomize position (global random value for whole squadron)
squadronAlt				equ zeropage+50 ; 1 byte	cache; 0 for alernative direction, >0 - normal direction    
squadronAddr			equ	zeropage+51	; 2 bytes	adress to selected squadron data	
enemyBombCounter		equ	zeropage+53	; 1 byte	enemy bombs counter
rapidusDetected			equ zeropage+54	; 1 byte	0 - running on 6502, $80 - running on 65c816. 
fntAlloc				equ zeroPage+55	; 4 bytes 	fonts for enemies

ntsc					equ zeropage+$3e ; 0 = PAL; other value = NTSC counter for VBL skip
ntsc_counter			equ zeropage+$3f ; skip VBL sound by this frames; 0 to disable NTSC (during gameplay, FX)
globalVelocityBuffer	equ zeropage+$40 ; -$7f ($3f bytes) fast global velocity buffer 
		
.local levelCurrent		; information about current level
	tokill 	  				equ zeroPage+$80 ; 1 byte
	agilityDelay			equ zeroPage+$81 ; 1 byte
	rotationDelay			equ zeroPage+$82 ; 1 byte
	bossKilled				equ zeroPage+$83 ; 1 byte
	allowSpawnsDelay		equ zeroPage+$84 ; 1 byte | delay before we can spawn anything in level
	allowSpawns				equ zeroPage+$85 ; 1 byte | 0 = spawns allowed (shots, enemies etc)
	enemyPeriodicity 		equ zeroPage+$86 ; 1 byte
	difficulty 				equ zeroPage+$87 ; 1 byte
	clearedLevels			equ zeroPage+$88 ; 1 byte
	explodeAll				equ zeroPage+$89 ; 1 byte
	agilityMinimum			equ zeroPage+$8a ; 1 byte ; enemy minimum agility (less = better agility)
	rotationDelayMin		equ zeroPage+$8b ; 1 byte
	enemyBossHP				equ zeroPage+$8c ; 1 byte
	enemyBossHalfHP			equ zeroPage+$8d ; 1 byte
	enemyFirePeriodicity	equ zeropage+$8e ; 1 byte
	squadronPeriodicity		equ zeropage+$8f ; 1 byte
	enemyBombPeriodicity	equ zeropage+$90 ; 1 byte
	swarmMode				equ zeropage+$91 ; 1 byte
.endl

; draw engine
prObjWidth		equ zeroPage+$92	; 1 byte	| current object width in bytes (4 pixels)
prObjHeight		equ zeroPage+$93	; 1 byte	| current object height
prGfxScr		equ zeroPage+$94	; 2 bytes	| sourca graphics address
prGfxMaskOff	equ zeroPage+$96	; 1 byte	| offset to corresponding mask data
prGfxNextOff	equ zeroPage+$97	; 4 bytes	| offset to next horizontal graphics
prObjId			equ zeroPage+$9c	; 1 byte	| index of  object in ebGfx* table


.local soundSystem							; what sound FX to play on what channel during VBL
	channelCounter		equ zeroPage+$a2	; 1 byte | channel counter - cycle sounds through channels [DEPRECATED] 
	soundChannelSFX		equ zeroPage+$a3 	; -$a6 4 bytes (4 channels)
	soundChannelNote	equ zeroPage+$a7 	; -$aa 4 bytes (4 channels)
	subsongQueue		equ zeroPage+$ab 	; 1 byte ; queued subsong to play (change on VBL)
.endl	


musicPlayerPage		equ zeroPage+$ac ; 19 bytes

;local temp variablesvariables for current running segment
zeroPageLocal	equ $c0 
_CopyFrom	equ zeroPageLocal
_CopyTo		equ zeroPageLocal+2
_CopyLength	equ zeroPageLocal+4 ; 2 bytes


; ***** ENGINE BUFFERS *****
prMaskTempTable equ objectListTable ; $100 bytes | temporary table for mask generations; shared buffer
ebGfxScrsL	equ $200 ;  - $23f
ebGfxScrsH	equ $240 ;  - $27f
ebGfxMaskO	equ $280 ;  - $2bf
ebGfxNextO	equ $2c0 ;  - $2ff 
playerMask  equ $340 ;  - $37f

; RENDERER BUFFER
egGfxData	equ $5900 ; max: $ad59

; NMI	
nmiHandler		equ	$ad60 ; - $add0)

; ***** GAME DATA *****
dataMusicPlayerTables	equ $addf ; - dummy - just for information (~$400 bytes frequency tables before RMT player)   
dataMusicPlayer			equ $b100 ; - $b4ff (can vary | check in final version)
dataMusicFile			equ $b500 ; - $beff RMT file | ($be4c for now)

; DLISTs
dataTitleScreenDlist 	equ $bf00 ; - $40 bytes	
dataTitleScreenDlist2 	equ $bf40 ; - $40 bytes
dataPlayfieldDlist	 	equ $bf80 ; - $40 bytes
dataPlayfieldDlist2		equ $bfc0 ; - $40 bytes

dataCloudSmall			equ $f000	; $20 bytes
dataCloudMedium			equ $f020	; $80 bytes
dataProgressBar1		equ $f0a0 	; $20 bytes
dataProgressBar2		equ $f0c0	; $20 bytes
dataProgressBar3		equ $f0e0	; $20 bytes
dataProgressBar4		equ $f100 	; $20 bytes
dataProgressBar5		equ $f120 	; $20 bytes
dataCloudBig			equ $f140	; $c0 bytes
 
; MAIN GFX DATA
; enemies, bosses, explosions, parachute, bombs, rockets, player
dataGameGraphic			equ $c000 ; - $cfff
dataEnemyLevel1			equ dataGameGraphic			; $400 bytes
dataEnemyLevel2			equ dataGameGraphic+$400	; $400 bytes
dataEnemyLevel4			equ dataGameGraphic+$800	; $400 bytes
dataEnemyBoss1			equ dataGameGraphic+$c00	; $100 bytes
dataEnemyBoss2			equ dataGameGraphic+$d00	; $100 bytes
dataEnemyBoss3			equ dataGameGraphic+$e00	; $100 bytes
dataEnemyBoss4			equ dataGameGraphic+$f00	; $100 bytes


dataGameGraphic2		equ $e000 ; - $efff
dataEnemyLevel3			equ dataGameGraphic2		; $240 bytes
dataEnemyLevel5			equ dataGameGraphic2+$240	; $80 bytes
dataEnemyExplosion		equ dataGameGraphic2+$2c0	; $100 bytes
dataParachute			equ dataGameGraphic2+$3c0	; $140 bytes
dataEnemyBoss5			equ dataGameGraphic2+$500	; $100 bytes
dataSpritePlayer		equ dataGameGraphic2+$600	; $400 bytes
dataAsteroidSmall		equ dataGameGraphic2+$a00   ; $40 bytes
dataAsteroidMedium		equ dataGameGraphic2+$a40   ; $80 bytes
dataAsteroidBig			equ dataGameGraphic2+$ac0   ; $120 bytes 
dataEnemyBomb			equ	dataGameGraphic2+$be0   ; $20 bytes 	
dataTextFonts 			equ dataGameGraphic2+$c00   ; $2a0 bytes	| last $150 fnt bytes used for gfx data 
dataEnemyBombLvl5		equ dataGameGraphic2+$ea0   ; $20 bytes
dataCosmonaut			equ dataGameGraphic2+$ec0   ; $140 bytes

; ***** GAME BUFFERS ******
objectListTable	equ $d800 	; - $dbff ; $400 bytes

bufFonts0a	equ $400		; - $400 bytes		; iteration of 4 pages
bufFonts1a	equ $800 		; - $400 bytes		; iteration of 4 pages
bufFonts2a	equ $c00 		; - $400 bytes		; iteration of 4 pages
bufFonts3a	equ $1000 		; - $400 bytes		; iteration of 4 pages

bufFonts0b	equ $1400 		; - $400 bytes		; iteration of 4 pages
bufFonts1b	equ $1800 		; - $400 bytes		; iteration of 4 pages
bufFonts2b	equ $1c00 		; - $400 bytes		; iteration of 4 pages
bufFonts3b	equ $dc00 		; - $400 bytes		; iteration of 4 pages

bufScreen0		equ $f200 	; - $f3ff
bufScreen1		equ $f400 	; - $f5ff
buf2FreePages	equ $f600 	; - $f7ff

bufPMBase	equ $f800 ; - $fbff				; iteration of 4 pages; only pages 2 and 3 used for sprites | first $200 used in various buffers
bufM		equ bufPMBase+$180
bufPM0		equ bufPMBase+$200
bufPM1		equ bufPMBase+$280
bufPM2		equ bufPMBase+$300
bufPM3		equ bufPMBase+$380

bufScreenTxt 	equ bufPMBase				; unused PMBase segment - used for score information
bufProgressBar	equ bufScreenTxt+40			; unused PMBase segment - used for level progress bar gfx

dataLogoFonts	equ $fc00 ; - $ffff

; ***** FREE RAM *****
; free: $ede0-edff  dataGameGraphic2+$de0 - $dff | $20 bytes
; $380	- $3ff	($80 bytes)

; ***** FREE RAM - BUFFERS ONLY *****
; $f600 - $f7ff ($200 bytes) can be only used for buffers;  used in: titlescreen drawTo buffer


