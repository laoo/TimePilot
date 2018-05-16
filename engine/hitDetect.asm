; HIT
; Hit detection

.proc	HIT

; ---------------------------------------------------
;	HIT DETECT MAIN LOOP - jump here every gameLoop
; ---------------------------------------------------
.proc mainLoop
	ldx #(engimeMaxPlayerShots-1)
loopShot
	lda ol.tab.type+olPlayerShots,x
	beq nextShot	
	
	lda ol.tab.type+olBoss				; boss
	beq @+
	jsr hitBoss	
@	
	
	ldy #(engineMaxCommon-1)			; common objects	
loopObj	
	lda ol.tab.type+olCommon,y
	cmp #ol.type.enemy
	bne @+
	
	jsr hitEnemy
	jmp nextObj
@	
	cmp #ol.type.bomb
	bne nextObj
	jsr hitBomb
	
nextObj
	dey
	bpl loopObj
nextShot	
	dex
	bpl loopShot
	rts 	
.endp

; In: Y = enemy, X = player shot
.proc hitEnemy
hitboxWidth		equ 16
hitboxHeight	equ 16
	
	; HITBOX - X
	lda ol.tab.posXH+olCommon,y
	cmp ol.tab.posXH+olPlayerShots,x
	bcs skip
	adc #hitboxWidth						; C is clear
	cmp ol.tab.posXH+olPlayerShots,x
	bcc skip
	
	; HITBOX - Y
	lda ol.tab.posYH+olCommon,y
	cmp ol.tab.posYH+olPlayerShots,x
	bcs skip
	adc #hitboxHeight					; C is clear
	cmp ol.tab.posYH+olPlayerShots,x
	bcc skip
	
	; HIT DETECTED
	lda #ol.type.explosion
	sta ol.tab.type+olCommon,y
	dec enemyCounter
	lda #0
	sta ol.tab.animationCounter+olCommon,y
	sta ol.tab.type+olPlayerShots,x
	jsr level.killEnemy
	;jsr level.killEnemy
	ldx #soundNumber
	ldy #soundNote
	stx soundSystem.soundChannelSFX+3
	sty soundSystem.soundChannelNote+3
	lda #gameEnemyScore
	jmp SCORE.scoreAdd
skip	
	rts
soundNumber			equ 3
soundNote			equ 0
	
.endp

; In: Y = bomb, X = player shot
.proc hitBomb
hitboxWidth		equ 11 
hitboxHeight	equ 9 
		
	; HITBOX - X
	lda ol.tab.posXH+olCommon,y
	sbc #3
	cmp ol.tab.posXH+olPlayerShots,x
	bcs skip
	adc #hitboxWidth						; C is clear
	cmp ol.tab.posXH+olPlayerShots,x
	bcc skip
	
	; HITBOX - Y
	lda ol.tab.posYH+olCommon,y
	sbc #3
	cmp ol.tab.posYH+olPlayerShots,x
	bcs skip
	adc #hitboxHeight						; C is clear
	cmp ol.tab.posYH+olPlayerShots,x
	bcc skip
	
	; HIT DETECTED
	lda #ol.type.explosion
	sta ol.tab.type+olCommon,y
	lda ol.tab.posXH+olCommon,y
	sbc #8
	sta ol.tab.posXH+olCommon,y
	lda ol.tab.posYH+olCommon,y
	sbc #8
	sta ol.tab.posYH+olCommon,y
	
	dec enemyBombCounter
	lda #0
	sta ol.tab.animationCounter+olCommon,y
	sta ol.tab.type+olPlayerShots,x
	ldx #soundNumber
	ldy #soundNote
	stx soundSystem.soundChannelSFX+3
	sty soundSystem.soundChannelNote+3
	lda #gameBombScore
	jmp SCORE.scoreAdd
skip	
	rts
soundNumber			equ 3
soundNote			equ 0
.endp

; In: X = player shot
.proc hitBoss
hitboxWidth		equ 32
hitboxHeight	equ 16
	
	; HITBOX - X
	lda ol.tab.posXH+olBoss
	cmp ol.tab.posXH+olPlayerShots,x
	bcs skip
	adc #hitboxWidth						; C is clear
	cmp ol.tab.posXH+olPlayerShots,x
	bcc skip
	
	; HITBOX - Y
	lda ol.tab.posYH+olBoss
	cmp ol.tab.posYH+olPlayerShots,x
	bcs skip
	adc #hitboxHeight						; C is clear
	cmp ol.tab.posYH+olPlayerShots,x
	bcc skip

	; HIT DETECTED
	lda #$80
	sta prPrepareGeneric.bossBlink
	lda #0
	sta ol.tab.type+olPlayerShots,x
	lda #gameBossHitScore
	jsr SCORE.scoreAdd
	dec levelCurrent.enemyBossHP
	bne @+
	lda #1
	sta levelCurrent.bossKilled
	lda #0
	sta ol.tab.type+olBoss
	lda #gameBossScore
	jsr SCORE.scoreAdd
	
@	
	ldx #soundNumber
	ldy #soundNote
	stx soundSystem.soundChannelSFX+3
	sty soundSystem.soundChannelNote+3
	
	
skip	
	rts
soundNumber			equ 3 ; or 11
soundNote			equ 0
.endp

; In: X = object number (enemy) in ol.tab list
; Out: A = 0 no collision | A = 1 - collision
; algorithm: Axis-Aligned Bounding Box
.proc hitPlayerEnemy
playerWidth			equ 8		; hitboxwidth
playerHeight		equ 8		; hitboxheight
enemyWidth			equ 16		
enemyHeight			equ 16
enemyHitboxWidth	equ 12		
enemyHitboxHeight	equ 12
enemyChangeX		equ (enemyWidth-enemyHitboxWidth)/2
enemyChangeY		equ (enemyHeight-enemyHitboxHeight)/2

playerX			equ prScreenXMin+(prScreenWidth/2)-playerWidth+4
playerY			equ prScreenYMin+(prScreenHeight/2)-playerHeight+4
playerX_W		equ playerWidth+playerX
playerY_H		equ playerHeight+playerY	
	
	clc
	lda ol.tab.posXH,x
	adc #enemyChangeX
	cmp #playerX_W
	bcs noColission
	; C is clear
	lda ol.tab.posXH,x
	adc #enemyHitboxWidth
	cmp #playerX
	bcc noColission
	lda ol.tab.posYH,x
	adc #enemyChangeY-1	;C is set
	cmp #playerY_H
	bcs noColission
	; C is clear
	lda ol.tab.posYH,x
	adc #enemyHitboxHeight
	cmp #playerY
	bcc noColission
	; colission
	lda #gameEnemyScore
	jsr SCORE.scoreAdd
	lda #1
	rts
	
noColission
	lda #0	
	rts
.endp

; In: X = object number (bomb) in ol.tab list
; Out: A = 0 no collision | A = 1 - collision
; algorithm: Axis-Aligned Bounding Box
.proc hitPlayerBomb
playerWidth			equ 8		; hitboxwidth
playerHeight		equ 8		; hitboxheight
bombWidth			equ 5		
bombHeight			equ 3
bombHitboxWidth		equ 3		
bombHitboxHeight	equ 2
bombChangeX			equ (bombWidth-bombHitboxWidth)/2
bombChangeY			equ (bombHeight-bombHitboxHeight)/2

playerX			equ prScreenXMin+(prScreenWidth/2)-playerWidth+4
playerY			equ prScreenYMin+(prScreenHeight/2)-playerHeight+4
playerX_W		equ playerWidth+playerX
playerY_H		equ playerHeight+playerY	
	
	clc
	lda ol.tab.posXH,x
	adc #bombChangeX
	cmp #playerX_W
	bcs noColission
	; C is clear
	lda ol.tab.posXH,x
	adc #bombHitboxWidth
	cmp #playerX
	bcc noColission
	lda ol.tab.posYH,x
	adc #bombChangeY-1 ;C is set
	cmp #playerY_H
	bcs noColission
	; C is clear
	lda ol.tab.posYH,x
	adc #bombHitboxHeight
	cmp #playerY
	bcc noColission
	; colission
	lda #gameBombScore
	jsr SCORE.scoreAdd
	lda #1
	rts
	
noColission
	lda #0	
	rts
.endp

; Out: A = 0 no collision | A = 1 - collision
; algorithm: Axis-Aligned Bounding Box
.proc hitPlayerBoss
playerWidth		equ 8		; hitboxwidth
playerHeight	equ 8		; hitboxheight
enemyWidth			equ 32		
enemyHeight			equ 16
enemyHitboxWidth	equ 32		
enemyHitboxHeight	equ 10
enemyChangeX		equ (enemyWidth-enemyHitboxWidth)/2
enemyChangeY		equ (enemyHeight-enemyHitboxHeight)/2

playerX			equ prScreenXMin+(prScreenWidth/2)-playerWidth+4
playerY			equ prScreenYMin+(prScreenHeight/2)-playerHeight+4
playerX_W		equ playerWidth+playerX
playerY_H		equ playerHeight+playerY	
	
	clc
	lda ol.tab.posXH+olBoss
	adc #enemyChangeX
	cmp #playerX_W
	bcs noColission
	; C is clear
	lda ol.tab.posXH+olBoss
	adc #enemyHitboxWidth
	cmp #playerX
	bcc noColission
	clc	
	lda ol.tab.posYH+olBoss
	adc #enemyChangeY
	cmp #playerY_H
	bcs noColission
	; C is clear
	lda ol.tab.posYH+olBoss
	adc #enemyHitboxHeight
	cmp #playerY
	bcc noColission
	; colission
	lda #gameBossScore
	jsr SCORE.scoreAdd
	lda #1
	rts
	
noColission
	lda #0	
	rts
.endp

.endp ; HIT
