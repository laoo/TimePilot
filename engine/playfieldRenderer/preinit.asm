
cPixelsPerByte	= 4
cPlanesPerObj	= 2	;graphics and mask

egGfxDataPtr	.ds 2
egGfxEnemyPtr	.ds 2	;pointer to beginning of enemy data
 
ebTmpGfxObj		equ zeroPageLocal+0	;object number
ebTmpHeight		equ zeroPageLocal+1
ebTmpWidth		equ zeroPageLocal+2
ebTmpSize		equ zeroPageLocal+3 ;w
ebTmpGfxSrc		equ zeroPageLocal+5	;w
ebTmpGfxStride	equ zeroPageLocal+7	;w

ebTmpFree		equ zeroPageLocal+9

.proc	prPreinitLvl1
	; OLP will use clouds
	lda #prPrepareGenericTypes.cloud1
	sta OLP.cloudSmall.type
    lda #prPrepareGenericTypes.cloud2
    sta OLP.cloudMedium.type
    lda #prPrepareGenericTypes.cloud3
    sta OLP.cloudBig.type

	jsr prPreinitShared
	jsr prPrepareGfxCloud1
	jsr prPrepareGfxCloud2
	jsr prPrepareGfxCloud3
	
	ldx #6
	jsr prPrepareGfxCommon		; explosion
	ldx #7
	jsr prPrepareGfxCommon		; parachute 
	ldx #9
	jsr prPrepareGfxCommon		; bomb

	jsr resetPlayerMask
	jmp clearBufFontsHidden
.endp

.proc	prPreinitLvl5
	; OLP will use asteroids
    lda #prPrepareGenericTypes.asteroid1
	sta OLP.cloudSmall.type
    lda #prPrepareGenericTypes.asteroid2
    sta OLP.cloudMedium.type
    lda #prPrepareGenericTypes.asteroid3
    sta OLP.cloudBig.type

	jsr prPreinitShared
	jsr prPrepareGfxAsteroid1
	jsr prPrepareGfxAsteroid2
	jsr prPrepareGfxAsteroid3
	
	ldx #6
	jsr prPrepareGfxCommon		; explosion
	ldx #8
	jsr prPrepareGfxCommon		; cosmomaut
	ldx #10
	jsr prPrepareGfxCommon		; bomb lvl 5 (missile)

	jsr resetPlayerMask
	jmp clearBufFontsHidden
.endp

.proc prPreinitShared
	lda #<egGfxData
	sta egGfxDataPtr
	lda #>egGfxData
	sta egGfxDataPtr+1
	lda #0
	sta egGfxEnemyPtr
	sta egGfxEnemyPtr+1
    sta prGfxNextOff    ;always 0
    ;fall through12
	;jmp prInitializePreparationTables
.endp

;preparation of table for mapping graphics bits to mask
;for each two bits mask is 11 if graphics is 0  
.proc prInitializePreparationTables

cnt		equ zeroPageLocal
tmp 	equ zeroPageLocal+1

	ldx #0
loop
	lda #4
	sta cnt
	txa
l0	
	sta tmp
	and #3
	tay
	lda prMaskTempTable,x
	lsr
	lsr
	ora tab,y
	sta prMaskTempTable,x
	lda tmp
	lsr
	lsr
	dec cnt
	bne l0
	inx
	bne loop
	rts
tab .he c0 00 00 00
.end

.proc prPrepareGfxPreamble
	ldx ebTmpGfxObj
	lda egGfxDataPtr
	sta ebGfxScrsL,x
	lda egGfxDataPtr+1
	sta ebGfxScrsH,x
	lda ebTmpHeight
	sta ebGfxMaskO,x
	asl
	sta ebGfxNextO,x
	lda egGfxDataPtr
	clc
	adc ebTmpSize
	sta egGfxDataPtr
	lda egGfxDataPtr+1
	adc ebTmpSize+1
	sta egGfxDataPtr+1
	rts
.endp

.proc prPrepareGfxCloud1
cWidth		= 4
cHeight		= 8

	lda #prGfxObj.cloud1
	sta ebTmpGfxObj
	lda #cHeight
	sta ebTmpHeight
	lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize
	lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize+1
	jsr prPrepareGfxPreamble
	lda #cWidth
	sta ebTmpWidth
	sta ebTmpGfxStride
	lda #0
	sta ebTmpGfxStride+1
	lda #<dataCloudSmall
	sta ebTmpGfxSrc
	lda #>dataCloudSmall
	sta ebTmpGfxSrc+1
	jmp prPrepareGfxConvert
.endp


.proc prPrepareGfxCloud2

cWidth		= 8
cHeight		= 14

	lda #prGfxObj.cloud2
	sta ebTmpGfxObj
	lda #cHeight
	sta ebTmpHeight
	lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize
	lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize+1
	jsr prPrepareGfxPreamble
	lda #cWidth
	sta ebTmpWidth
	sta ebTmpGfxStride
	lda #0
	sta ebTmpGfxStride+1
	lda #<(dataCloudMedium+cWidth)	;skipping one empty line
	sta ebTmpGfxSrc
	lda #>(dataCloudMedium+cWidth)
	sta ebTmpGfxSrc+1
	jmp prPrepareGfxConvert
.endp

.proc prPrepareGfxCloud3

cWidth		= 12
cHeight		= 15


	lda #prGfxObj.cloud3
	sta ebTmpGfxObj
	lda #cHeight
	sta ebTmpHeight
	lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize
	lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize+1
	jsr prPrepareGfxPreamble
	lda #cWidth
	sta ebTmpWidth
	sta ebTmpGfxStride
	lda #0
	sta ebTmpGfxStride+1
	lda #<(dataCloudBig+cWidth)	;skipping one empty line
	sta ebTmpGfxSrc
	lda #>(dataCloudBig+cWidth)
	sta ebTmpGfxSrc+1
	jmp prPrepareGfxConvert
.endp

; ASTEROIDS
.proc prPrepareGfxAsteroid1

cWidth		= 4
cHeight		= 15

	;cloud1 is 16x8 pixels
	;4 bytes horizontally and 8 bytes vertically

	lda #prGfxObj.cloud1
	sta ebTmpGfxObj
	lda #cHeight
	sta ebTmpHeight
	lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize
	lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize+1
	jsr prPrepareGfxPreamble
	lda #cWidth
	sta ebTmpWidth
	sta ebTmpGfxStride
	lda #0
	sta ebTmpGfxStride+1
	lda #<dataAsteroidSmall
	sta ebTmpGfxSrc
	lda #>dataAsteroidSmall
	sta ebTmpGfxSrc+1
	jmp prPrepareGfxConvert
.endp


.proc prPrepareGfxAsteroid2

cWidth		= 8
cHeight		= 14

	lda #prGfxObj.cloud2
	sta ebTmpGfxObj
	lda #cHeight
	sta ebTmpHeight
	lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize
	lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize+1
	jsr prPrepareGfxPreamble
	lda #cWidth
	sta ebTmpWidth
	sta ebTmpGfxStride
	lda #0
	sta ebTmpGfxStride+1
	lda #<(dataAsteroidMedium+cWidth)	;skipping one empty line
	sta ebTmpGfxSrc
	lda #>(dataAsteroidMedium+cWidth)
	sta ebTmpGfxSrc+1
	jmp prPrepareGfxConvert
.endp

.proc prPrepareGfxAsteroid3

cWidth		= 12
cHeight		= 21

	lda #prGfxObj.cloud3
	sta ebTmpGfxObj
	lda #cHeight
	sta ebTmpHeight
	lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize
	lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize+1
	jsr prPrepareGfxPreamble
	lda #cWidth
	sta ebTmpWidth
	sta ebTmpGfxStride
	lda #0
	sta ebTmpGfxStride+1
	lda #<dataAsteroidBig	
	sta ebTmpGfxSrc
	lda #>dataAsteroidBig
	sta ebTmpGfxSrc+1
	//fall through
;	jmp prPrepareGfxConvert
.endp

.proc prPrepareGfxConvert
    
dstPtrBase  equ ebTmpFree
dstPtr      equ ebTmpFree+2
cntY        equ ebTmpFree+4
cntX        equ ebTmpFree+5
tmpl        equ ebTmpFree+6
tmp         equ ebTmpFree+7
tmpr        equ ebTmpFree+8
cnt         equ ebTmpFree+9
dstStride   equ ebTmpFree+10
srcPtr      equ ebTmpFree+11


    ldx ebTmpGfxObj
    lda ebGfxScrsL,x
    sta dstPtrBase
    lda ebGfxScrsH,x
    sta dstPtrBase+1
    lda ebGfxNextO,x
    sta dstStride
    lda ebTmpHeight
    sta cntY
    
loopy
    lda ebTmpWidth
    sta cntX
    lda ebTmpGfxSrc
    sta srcPtr
    lda ebTmpGfxSrc+1
    sta srcPtr+1
    
    lda dstPtrBase
    sta dstPtr
    lda dstPtrBase+1
    sta dstPtr+1
    lda #0
    sta tmpr

loopxOuter
    lda tmpr
    sta tmpl
    ldy #0
    lda (srcPtr),y
    sta tmp
    lda #4
    sta cnt
loopxInner
    lda tmp
    ldy #0
    sta (dstPtr),y
    tax
    lda prMaskTempTable,x
    ldy ebTmpHeight
    sta (dstPtr),y  ;mask is by 'height' further than gfx
    lda tmpl
    lsr
    ror tmp
    ror tmpr
    lsr
    ror tmp
    ror tmpr
    sta tmpl
    lda dstPtr
    clc
    adc dstStride
    sta dstPtr
    bcc @+
    inc dstPtr+1
@   dec cnt
    bne loopxInner
    inc srcPtr
    bne @+
    inc srcPtr+1
@   dec cntX
    bmi @+
    bne loopxOuter
    lda tmpr
    sta tmpl
    lda #0
    sta tmp
    lda #4
    sta cnt
    bne loopxInner
    
@   inc dstPtrBase
    bne @+
    inc dstPtrBase+1
@   lda ebTmpGfxSrc
    clc
    adc ebTmpGfxStride
    sta ebTmpGfxSrc
    lda ebTmpGfxSrc+1
    adc ebTmpGfxStride+1
    sta ebTmpGfxSrc+1
    dec cntY
    jne loopy
    rts
.endp

.proc prPrepareGfxCommonInit
	lda egGfxEnemyPtr+1
	beq firstTime
	lda egGfxEnemyPtr
	sta egGfxDataPtr
	lda egGfxEnemyPtr+1
	sta egGfxDataPtr+1
	bne @+
firstTime
	lda egGfxDataPtr
	sta egGfxEnemyPtr
	lda egGfxDataPtr+1
	sta egGfxEnemyPtr+1
@
	rts
.endp

; prepares animations graphics | common objects (sizes: 8, 16)
; X = object animation number
; 1-5 enemies | 6 explosion | 7 parachute | 8 astronaut | 9 bomb
.proc prPrepareGfxCommon
	dex
	txa
	pha
	
	jsr prInitializePreparationTables
	
	pla
	tax
	
	sta animationNumber
	lda animationFrames,x		; how many animation frames for this object
	sta aniFrames+1
	lda animationL,x
	sta autoL+2
	lda animationH,x
	sta autoH+1
	lda #0
	sta frame

loop
	ldy animationNumber
	lda animationObj,y
	clc
	adc frame 
	sta ebTmpGfxObj
	lda height,y
	sta ebTmpHeight	
	lda sizeL,y
	sta ebTmpSize
	lda sizeH,y
	sta ebTmpSize+1
	jsr prPrepareGfxPreamble	; y is not used there
	lda width,y
	sta ebTmpWidth
	ldy animationNumber
	lda cStrideL,y
	sta ebTmpGfxStride
	lda cStrideH,y
	sta ebTmpGfxStride+1
	lda frame				; frame * width (width: 16)
	asl						; *2	(width:8)
	cpy #8					; bomb
	beq autoL
	cpy #9					; ufo missile
	beq autoL
	asl						; *4	(width: 16)
autoL	
	clc			
	adc #<dataEnemyLevel1	; code-modified value
	sta ebTmpGfxSrc
autoH
	lda #>dataEnemyLevel1	; code-modified value
	sta ebTmpGfxSrc+1
	jsr prPrepareGfxConvert
	
	inc frame
	lda frame
aniFrames	
	cmp #16					; code-modified value (different per object)
	bcc loop
	rts
	
; 1-5 enemies | 6 explosion | 7 parachute |  8 cosmonaut | 9 bomb | 10 ufo missile
animationL			dta l(dataEnemyLevel1), l(dataEnemyLevel2),l(dataEnemyLevel3), l(dataEnemyLevel4), l(dataEnemyLevel5), l(dataEnemyExplosion), l(dataParachute), l(dataCosmonaut), l(dataEnemyBomb), l(dataEnemyBombLvl5)
animationH			dta h(dataEnemyLevel1), h(dataEnemyLevel2),h(dataEnemyLevel3), h(dataEnemyLevel4), h(dataEnemyLevel5), h(dataEnemyExplosion), h(dataParachute), h(dataCosmonaut), h(dataEnemyBomb), h(dataEnemyBombLvl5)
animationObj	 	dta b(prGfxObj.enemy),b(prGfxObj.enemy),b(prGfxObj.enemy),b(prGfxObj.enemy),b(prGfxObj.enemy),b(prGfxObj.explosion),b(prGfxObj.parachute),b(prGfxObj.parachute),b(prGfxObj.bomb),b(prGfxObj.bomb)
animationFrames 	dta b(16),b(16),b(9),b(16),b(2),b(4),b(5),b(5),b(2),b(2)						; animation frames
cStrideL			dta l(4*16),l(4*16),l(4*9),l(4*16),l(4*2),l(4*4),l(4*5),l(4*5),l(2*2),l(2*2)	; chars x animationFrames
cStrideH			dta h(4*16),h(4*16),h(4*9),h(4*16),h(4*2),h(4*4),h(4*5),h(4*5),h(2*2),h(2*2)	; chars x animationFrames
width				dta b(4),b(4),b(4),b(4),b(4),b(4),b(4),b(4),b(2),b(2)							; animation width in chars (*cPixelsPerByte = in pixels)
height				dta b(16),b(16),b(16),b(16),b(16),b(16),b(16),b(16),b(8),b(8)					; animation height in pixels
animationNumber 	dta b(0)																		; local temp
frame				dta b(0)																		; local temp

; <((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj) 
; >((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
sizeL				dta l(5*16*cPixelsPerByte*cPlanesPerObj),l(5*16*cPixelsPerByte*cPlanesPerObj),l(5*16*cPixelsPerByte*cPlanesPerObj),l(5*16*cPixelsPerByte*cPlanesPerObj),l(5*16*cPixelsPerByte*cPlanesPerObj)
					dta l(5*16*cPixelsPerByte*cPlanesPerObj),l(5*16*cPixelsPerByte*cPlanesPerObj),l(5*16*cPixelsPerByte*cPlanesPerObj),l(3*8*cPixelsPerByte*cPlanesPerObj),l(3*8*cPixelsPerByte*cPlanesPerObj)
sizeH				dta h(5*16*cPixelsPerByte*cPlanesPerObj),h(5*16*cPixelsPerByte*cPlanesPerObj),h(5*16*cPixelsPerByte*cPlanesPerObj),h(5*16*cPixelsPerByte*cPlanesPerObj),h(5*16*cPixelsPerByte*cPlanesPerObj)
					dta h(5*16*cPixelsPerByte*cPlanesPerObj),h(5*16*cPixelsPerByte*cPlanesPerObj),h(5*16*cPixelsPerByte*cPlanesPerObj),h(3*8*cPixelsPerByte*cPlanesPerObj),h(3*8*cPixelsPerByte*cPlanesPerObj)
 
.endp

; OBJECTS 32x16
; X = boss number (1-5)
.proc prPrepareGfxBoss
cWidth		= 8
cHeight		= 16

	dex
	txa
	pha

	jsr prInitializePreparationTables
	
	pla
	tax
	sta animationNumber
	lda animationFrames,x		; how many animation frames for this level 
	sta aniFrames+1
	lda animationL,x
	sta autoL+1
	lda animationH,x
	sta autoH+1
	lda #0
	sta frame

loop
	ldy animationNumber
	lda animationObj,y
	clc
	adc frame 
	sta ebTmpGfxObj
	lda #cHeight
	sta ebTmpHeight
	lda #<((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize
	lda #>((cWidth+1)*cHeight*cPixelsPerByte*cPlanesPerObj)
	sta ebTmpSize+1
	jsr prPrepareGfxPreamble
	lda #cWidth
	sta ebTmpWidth
	ldy animationNumber
	lda cStrideL,y
	sta ebTmpGfxStride
	lda cStrideH,y
	sta ebTmpGfxStride+1
	lda frame
	asl						; determines animation stride
	asl
	asl
autoL
	adc #<dataEnemyBoss1
	sta ebTmpGfxSrc
autoH
	lda #>dataEnemyBoss1
	sta ebTmpGfxSrc+1
	jsr prPrepareGfxConvert
	
	ldx frame
	inx
	stx frame
aniFrames	
	cpx #16
	bcc loop
	rts


frame	.he 0
animationL			dta l(dataEnemyBoss1), l(dataEnemyBoss2),l(dataEnemyBoss3), l(dataEnemyBoss4), l(dataEnemyBoss5)
animationH			dta h(dataEnemyBoss1), h(dataEnemyBoss2),h(dataEnemyBoss3), h(dataEnemyBoss4), h(dataEnemyBoss5)
animationObj	 	dta b(prGfxObj.boss),b(prGfxObj.boss),b(prGfxObj.boss),b(prGfxObj.boss),b(prGfxObj.boss)
animationFrames 	dta b(2),b(2),b(2),b(2),b(2)								; animation frames (boss 1-5)
cStrideL			dta l(8*2),l(8*2),l(8*2),l(8*2),l(8*2)						; 4 chars x animationFrames
cStrideH			dta h(8*2),h(8*2),h(8*2),h(8*2),h(8*2)						; 4 chars x animationFrames
animationNumber 	dta b(0)													; local temp
 
.endp


