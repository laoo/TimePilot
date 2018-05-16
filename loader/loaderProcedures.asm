


.proc 	loader
disableOS
    sei
    lda #0
    sta nmien      
    lda portb
    ldy #%11111110
    sty portb       
    and #%11111110  
    sta portb       
    rts

enableOS    
	lda portb
    ldy #%11111111
    sty portb       
    ora #%00000001  
    sta portb       
    lda #%11000000  
    sta nmien       
    cli
    rts   		
.endp

