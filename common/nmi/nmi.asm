; NMI + few procedures
; this block of code MAY not be longer than $ad60-$adde 

	org 	nmiHandler

.proc	NMI
		bit nmist ; what interruption VBL or DLI ? 
	 	bpl no
DLI		jmp dull
no		sta nmist
VBL		jmp dull

dull	rti
.endp


; .align $100
; warning: it MAY NOT cross page boundary (example $31f8 ->$3208)
; it is included at ~$ad60 	
bufDLIJumps
	dta a(DLI0)
	dta a(DLI1)
	dta a(DLI2)
	dta a(DLI3)
	dta a(DLI4)
bufDLIJumpsLevelStart
	dta a(DLI0)
	dta a(DLI1b)
	dta a(DLI2)
	dta a(DLI3b)
	dta a(DLI4b)
bufDLIJumpsGameOver
	dta a(DLI0)
	dta a(DLI1c)
	dta a(DLI2)
	dta a(DLI3b)
	dta a(DLI4b)

.proc	enableNMI
	lda <NMI
	sta $fffa
	lda >NMI
	sta $fffb
	lda #$c0    
	sta nmien 
	rts
.endp

; Various waitFrame procedures
.proc waitJoyXFrames
	jsr waitFrameNormal
	dex
	beq @+
	lda porta
	eor #$ff
	and #$f
	cmp #1 	
	beq @+
	cmp #2
	beq @+
	cmp #4
	beq @+
	lda trig0
	beq @+
	bne waitJoyXFrames
@	rts
.endp	

.proc waitXFrames ; X = how many frames to wait
	jsr waitFrameNormal
	dex
	bne waitXFrames
	rts
.endp

.proc 	waitFrame
l1	lda vcount
	cmp #engineWaitFrameVcount
	bcc l1
	rts
.endp

.proc 	waitFrameNormal
l1	lda vcount
	bne l1
l2	lda vcount
	beq l2
	rts
.endp

; this block of code MAY not be longer than $ad60-$adde 
	
	
