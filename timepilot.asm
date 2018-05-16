; -----------------------------------
;             TIMEPILOT
;	arcade port for Atari XL/XE 64K
;     	   code: solo, laoo
; 	     New Generation 2018
;------------------------------------

	icl 'loader/loadingFadeOut.asm'
	ini $5c00
	
	opt c+
	
	icl 'loader/loadGameGraphic.asm'
	ini $2000
	
	org $2000
	
start
	; preinitializations
	jsr gameInit.system
	
.proc 	main
	jsr gameInit.disablePM
	jsr prPreinitLvl1
	jsr gameInit.settings
	jsr titleScreen
	jsr initPlayfield
	jmp gameplay.loop
.endp
	
	; nmi 
	icl 'common/nmi/titleScreenNMI.asm'
	icl 'common/nmi/playfieldNMI.asm'

	; commons
	icl 'common/hardwareRegisters.asm'
	icl 'common/config.asm'
	icl 'common/memoryLayout.asm'
	
	; engine
	icl 'engine/drawPlayer.asm'
	icl 'engine/gameplayLoop.asm'
	icl 'engine/playfieldRenderer/main.asm'
	icl 'engine/levelProcedures.asm'
	icl 'engine/gameSpawns.asm'
	icl 'engine/objectListProcessing.asm'
	icl 'engine/objectListTable.asm'
	icl 'engine/hitDetect.asm'
	icl 'engine/enemyFire.asm'
	icl 'engine/enemyBomb.asm'
	icl 'engine/scoreRoutines.asm'
	icl 'engine/gameModes.asm'

	; various
	icl 'common/commonProcedures.asm'
	icl 'common/gameInit.asm'
	icl 'common/playfieldInit.asm'
	icl 'common/playfieldProcessing.asm'
	icl 'common/titleScreen.asm'
	icl 'common/drawTo.asm'
	icl 'common/soundSystem.asm' 

	; ORG ins starts here
	icl 'common/dlists/titleScreenDlist.asm'
	icl 'common/dlists/playfieldDlist.asm'
	icl 'common/rmt/rmtplayr.asm'
	icl 'common/nmi/nmi.asm'
		
	; music/sfx	
	opt h-
	ins "data/music/timepilot.rmt"
	opt h+
	
	run $2000
