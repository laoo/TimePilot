
.proc sound
init		jmp	soundInit
queueSFX	jmp	soundQueueSFX	; X = SFX number , Y = SFX note

.proc soundInit
	lda #$f0					; initial value
	sta RMT.RMTSFXVOLUME		; sfx note volume * 16 (0,16,32,...,240)
	lda #0
changeSong						; jump here with A = song line number
	ldx #configSoundAllow
	bne @+
	rts
@	ldx #<dataMusicFile			
	ldy #>dataMusicFile
	pha
	jsr waitFrameNormal
	pla
	jmp RMT.RASTERMUSICTRACKER		
.endp

.proc soundQueueSFX
	rts	

.print "Code end at ", *
	
	; CHANNEL QUEUING DISABLED (WIP)
	; for now we use:
 
	; channel0 - subsongs / enemy shots (if channel is free)
	; channel1 - player shots / enemy shots 
	; channel2 - looped sounds (boss, rockets) 
	; channel3 - explosions
 
	;lda RMT.trackn_idx			; subsong is playing on channel0 - we skip this channel for SFX
	;cmp #3
	;bcs @+
	;lda soundSystem.soundChannelSFX
	;bne @+
	;stx soundSystem.soundChannelSFX
	;sty soundSystem.soundChannelNote
	;rts
;@	
	;lda soundSystem.soundChannelSFX+1
	;bne noFreeChannels
	;stx soundSystem.soundChannelSFX+1
	;sty soundSystem.soundChannelNote+1
	;rts
@	
	; WIP: channel2 reserved for looped subsongs
	;lda soundSystem.soundChannelSFX+2
	;bne noFreeChannels
	;stx soundSystem.soundChannelSFX+2
	;sty soundSystem.soundChannelNote+2
	;rts
@;	
	;WIP: channel3 reserved for explosions
	;lda soundSystem.soundChannelSFX+3
	;bne noFreeChannels
	;stx soundSystem.soundChannelSFX+3
	;sty soundSystem.soundChannelNote+3
	;rts
;noFreeChannels				; if no free channels - we use channel 0/1 to force play SFX
	;lda RMT.trackn_idx		; is channel0 free? (subsongs there)
	;cmp #3
	;bcs @+
	;stx soundSystem.soundChannelSFX
	;sty soundSystem.soundChannelNote
;@		
	;stx soundSystem.soundChannelSFX+1
	;sty soundSystem.soundChannelNote+1
	;rts

	
.endp

.endp	; sound




