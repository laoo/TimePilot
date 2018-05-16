
prScreenWidth	= 160
prScreenHeight	= 96

prScreenWidthFonts	= prScreenWidth/4
prScreenHeightFonts	= prScreenHeight/8

;virtual screen coordinates
prScreenXMin	= 128-(prScreenWidth/2)
prScreenXMax	= 128+(prScreenWidth/2)
prScreenYMin	= 128-(prScreenHeight/2)
prScreenYMax	= 128+(prScreenHeight/2)

; object box size for fadeOut
fadeOutWidth	equ 16	; after this amount of pixels object will start to fade out off screen
fadeOutHeight	equ 16	; after this amount of pixels object will start to fade out off screen

rliTemp equ zeroPageLocal

rliMask		equ rliTemp+0

bufRLIDsL equ rliTemp+2 ;render list destination low
bufRLIDsH equ rliTemp+3 ;render list destination high
bufRLISrL equ rliTemp+4 ;render list source low
bufRLISrH equ rliTemp+5 ;render list source high
bufRLIDof equ rliTemp+6 ;render list destination offset
bufRLILen equ rliTemp+7 ;render list length (same as offset)
bufRLIMsk equ rliTemp+8 ;render list mask offset from dest
bufRLIVal equ rliTemp+9 ;render list destination value

prTemp equ zeroPageLocal+7	;this is madness!


;graphics objects ids | max 64 objects (0-63)
.enum prGfxObj
enemy	= 0			;16 entries
explosion = 16 		;4 entries
parachute = 20 		;5 entries
boss = 25 			;2 entries
cloud1	= 27		;1 entry
cloud2	= 28		;1 entry
cloud3	= 29		;1 entry
bomb	= 30		;2 entries
rocket	= 32		;16 entries

.ende

fontsReservedForPlayerLocation equ 256-8

	icl 'preinit.asm'
	icl 'preparePhase.asm'
	icl 'draw.asm'
	icl 'render.asm'
	
