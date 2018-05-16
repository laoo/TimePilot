
.proc copyText
	sta color+1
	stx _CopyFrom
	sty _CopyFrom+1
	
	lda #<bufScreenTxt
	sta copyTo+1
	lda #>bufScreenTxt
	sta copyTo+2
	ldy #0
	lda (_CopyFrom),y
	tax
	iny
	lda (_CopyFrom),y
	tay
	beq start
posy
	adw copyTo+1 #20
	dey
	bne posy
start	
	ldy #2
copy	
	lda (_CopyFrom),y
	cmp #3 				; ' # '
	beq done
color	ora #%01000000		
copyTo	sta bufScreenTxt,x
	inx
	iny
	bne copy ;!
done
	rts
	
.endp

.proc	clearBufPM
	lda #0
	tax
loop
	sta bufPM0,x
	sta bufPM2,x
	inx
	bne loop
	rts
.endp

.proc clearBufScreenTxt 
	lda #0
	tax
lo	sta bufScreenTxt,x
	sta bufScreenTxt+$100,x
	inx
	bne lo
	rts
.endp


.proc	loaderFadeOut
	ldy #15
continue	
	ldx #2
loop	
	lda 708,x
	and #$f
	beq next
	dec 708,x
next
	dex
	bpl loop
	jsr waitFrameNormal 
	jsr waitFrameNormal
	jsr waitFrameNormal
	dey
	bne continue
	lda #0
	sta 708
	sta 709
	sta 710
	jmp waitFrameNormal
.endp

;returns $80 for 65c816 and $00 for 6502 
.proc detectCPU
	lda #$99
	clc
	sed
	adc #$01
	cld
	beq CPU_CMOS

CPU_02
	lda #0
	sta rapidusDetected
	rts

CPU_CMOS
	lda #0
	rep #%00000010		;wyzerowanie bitu Z
	beq CPU_02

CPU_C816
	lda #$80
	sta rapidusDetected
	rts
.endp

; temporary solution for BOSS sound - if boss on screen we replay boss sound (because 'changeSong' resets it and we use changeSong for parachute pickup/additional life)
.proc	fixBossSound
	lda levelCurrent.toKill
	bne @+
	lda levelCurrent.enemyBossHP
	beq @+
	ldy gameCurrentLevel
	dey
	ldx SPAWN.boss.soundNumber,y
	ldy #SPAWN.boss.soundNote
	stx soundSystem.soundChannelSFX+2
	sty soundSystem.soundChannelNote+2
@	
	rts
.endp

; new level values for rapidus (agility, periodicity, rotation delays etc)
.proc	rapidusLevelValues
	lda #<levelInformation.rapidusLevelRotationDelayMin
	sta _CopyFrom
	lda #>levelInformation.rapidusLevelRotationDelayMin
	sta _CopyFrom+1
	lda #<levelInformation.levelRotationDelayMin
	sta _CopyTo
	lda #>levelInformation.levelRotationDelayMin
	sta _CopyTo+1
	ldy #45-1
	;fall through (instead of jmp memCopyShort)
.endp

; SIMPLE MEMCOPY
; Y = block lenght (max 128 bytes)
; _CopyFrom = source |  _CopyTo = destination 
.proc memCopyShort	
loop                
    lda (_CopyFrom),y
    sta (_CopyTo),y
    dey
    bpl loop
    rts
.endp     


; new level values for rapidus (agility, periodicity, rotation delays etc)
.proc	prepareGlobalVelocity
	lda #<OLP.globalVelocityTab
	sta _CopyFrom
	lda #>OLP.globalVelocityTab
	sta _CopyFrom+1
	lda #<globalVelocityBuffer
	sta _CopyTo
	lda #>globalVelocityBuffer
	sta _CopyTo+1
	ldy #64-1
	
	bne memCopyShort
.endp


.proc 	disableOS
	lda #0
	sta nmien			; NMI off
	sei					; IRQ off
	lda #$fe			; RAM under ROM on | OS off
	sta portb
	rts
.endp
