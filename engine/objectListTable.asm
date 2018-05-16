; ENGINE OL OFFSETS
olPlayerShots 	equ 0		; 0-7			= player shots
olParachute 	equ 8		; 8   			= parachute
olBoss		 	equ 9		; 9   			= boss
olEnemyShots 	equ 10		; 10-11 		= enemy shots
olClouds 		equ 12		; 12-23 		= clouds	
olCommon 		equ 24		; 24-$capacity 	= common (enemies, bombs, rockets, explosions) | IMPORTANT: olCommon must be last sublist


; object list table
.local ol
base		equ objectListTable
capacity	equ $30							; number of elements in object list
.local tab

// example usage: ol.tab.frame+olEnemies,x | x - object number in local list  

//tables used by rendering engine
type			equ base + capacity*$0		;type of object
frame			equ base + capacity*$1		;frame number
posXL			equ base + capacity*$2		;lower byte of horizontal position
posXH			equ base + capacity*$3		;upper byte of horizontal position
posYL			equ base + capacity*$4		;lower byte of vertical position
posYH			equ base + capacity*$5		;upper byte of vertical position
//tables used for object velocity
velXL			equ base + capacity*$6		;lower byte of horizontal velocity
velXH			equ base + capacity*$7		;upper byte of horizontal velocity
velYL			equ base + capacity*$8		;lower byte of vertical velocity
velYH			equ base + capacity*$9		;upper byte of vertical velocity

//tables used for object logic
fadeOut						equ base + capacity*$a					; Object fade-out value | dec when object is not on screen | if 0 then destroy the object
rotationTargetFrame			equ base + capacity*$b		; target frame for rotation
rotationDelay				equ base + capacity*$c		; delay for rotation for each frame (used if rotation is in progress)
agilityDelay				equ base + capacity*$d		; delay before draw/rnd new rotation
animationCounter			equ base + capacity*$e 		; animation counter (for fixed animations)
movementDelay				equ base + capacity*$f		; delay before we process next object movemenet
rotationDirection 			equ base + capacity*$10		; direction of object rotation (left/right: {iny} or {dey})  
globalVelocitySpawnFrame 	equ base + capacity*$11		; globalVelocity player frame for spawn (used in enemy shots)
enemyShotIsAllowed			equ base + capacity*$12		; 0 - not | 1-255 - allowed | can enemy shoot? (once per spawn); prevent double-shotting
enemyBombIsAllowed			equ base + capacity*$13		; 0 - not | 1-255 - allowed | can enemy shoot? (once per spawn); prevent double-shotting
enemyBombDirection			equ base + capacity*$14		; 0 - down | 1 - up (UFO)
; free: 1 field

.endl ;tab

/*
	order of elements in the list in not important. The drawing engine must be called in specific order
 	- small and medium clouds
	- enemy ships and bombs
	- enemy fire
	- player fire, it returns whether it hit some enemy (returns index in the table, 0 if no hit, so at index 0 there must not be an enemy)
	- explosions
	- big cloud 
*/
.enum type
	empty 		= $00		;empty slot
	cloud1		= $01		;small cloud
	cloud2		= $02		;medium cloud
	cloud3		= $03		;big cloud
	enemy		= $10		;enemy plane
	rocket		= $11		;enemy rocket
	boss		= $12		;enemy boss
	bomb		= $13		;enemy bomb
	fire_e		= $20		;enemy fire
	fire_p		= $21		;player fire
	explosion	= $30		;enemy explosion
	parachute	= $40		;parachute
.ende


.endl ;ol