; ----------------------------------
; 			DATA LOADER
;	copy gfx data to RAM under ROM
;-----------------------------------

	org $2000
copyFm		equ $3000	; $1000
copyFm2		equ $4000	; $1000
copyFm3		equ $5000	; $400
copyFm4		equ $5400	; $200

	jsr loader.disableOS

	; gameGraphic
	.macro copyDataObjects 
	lda copyFm+$000+(:1<<8),x
	sta dataGameGraphic+$000+(:1<<8),x
	.endm
	ldx #0
@	.rept 16
	copyDataObjects .R
	.endr
	inx
	bne @-
	
	; gameGraphic2	
	.macro copyDataObjects2
	lda copyFm2+$000+(:1<<8),x
	sta dataGameGraphic2+$000+(:1<<8),x
	.endm
	ldx #0
@	.rept 16
	copyDataObjects2 .R
	.endr
	inx
	bne @-

	; gameGraphic3
	.macro copyDataObjects3
	lda copyFm3+$000+(:1<<8),x
	sta dataLogoFonts+$000+(:1<<8),x
	.endm
	ldx #0
@	.rept 4
	copyDataObjects3 .R
	.endr
	inx
	bne @-
	
	; gameGraphic4	(clouds, progress bars)
	.macro copyDataObjects4
	lda copyFm4+$000+(:1<<8),x
	sta dataCloudSmall+$000+(:1<<8),x
	.endm
	ldx #0
@	.rept 2
	copyDataObjects4 .R
	.endr
	inx
	bne @-	

	; determines PAL or NTSC
	ldx $d014
	dex
	beq @+
	ldx #7
@	
	stx $f600	; game reads it and store information on zero page
	
	; finish	
	jmp loader.enableOS

	icl 'loader/loaderProcedures.asm'
	
	org copyFm
	ins 'data/graphic/enemies/enemyLevel1.dat'
	ins 'data/graphic/enemies/enemyLevel2.dat'
	ins 'data/graphic/enemies/enemyLevel4.dat'
	ins 'data/graphic/enemies/bossLevel1.dat'
	ins 'data/graphic/enemies/bossLevel2.dat'
	ins 'data/graphic/enemies/bossLevel3.dat'
	ins 'data/graphic/enemies/bossLevel4.dat'

	org copyFm2
	ins 'data/graphic/enemies/enemyLevel3.dat'
	ins 'data/graphic/enemies/enemyLevel5.dat'
	ins 'data/graphic/enemies/enemyExplosion.dat'
	ins 'data/graphic/bonuses/parachute.dat'
	
	ins 'data/graphic/enemies/bossLevel5.dat'
	ins 'data/graphic/player.raw'
	ins 'data/graphic/asteroids/asteroidSmall.dat'
	ins 'data/graphic/asteroids/asteroidMedium.dat'
	ins 'data/graphic/asteroids/asteroidBig.dat'
	ins 'data/graphic/enemies/bomb.dat'
	
	org copyFm2+(dataTextFonts-dataGameGraphic2)
	ins 'data/graphic/timePilotFonts.fnt'
	ins 'data/graphic/enemies/bomb_lvl5.dat'
	ins 'data/graphic/bonuses/cosmonaut.dat'
	
	org copyFm3
	ins 'data/graphic/titleScreenLogo.fnt'
	
	org copyFm4
	ins 'data/graphic/clouds/cloudSmall.dat'
	ins 'data/graphic/clouds/cloudMedium.dat'
	
	ins 'data/graphic/progressBar/levelBar1.dat'
	ins 'data/graphic/progressBar/levelBar2.dat'
	ins 'data/graphic/progressBar/levelBar3.dat'
	ins 'data/graphic/progressBar/levelBar4.dat'
	ins 'data/graphic/progressBar/levelBar5.dat'
	ins 'data/graphic/clouds/cloudBig.dat'
	

	
	

	