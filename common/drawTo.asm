******************************************************************************
*                                                                            *
*  DRAW LINE                                                                 *
*                                                                            *
******************************************************************************
* Fast draw by Roland, Solo
* modified for TimePilot

.proc drawTo
size equ 40
tabys	equ buf2FreePages 		; temporary using buf2FreePages as table buf; 256bytes
tabym 	equ buf2FreePages+$100 	; temporary using buf2FreePages as table buf; 256bytes
aux		equ	zeroPageLocal
adr		equ zeroPageLocal+1
x1		equ zeroPageLocal+3
x2		equ zeroPageLocal+4
y1		equ zeroPageLocal+5
y2		equ zeroPageLocal+6
dx		equ zeroPageLocal+7
dy		equ zeroPageLocal+8
ax		equ zeroPageLocal+9
ay		equ zeroPageLocal+10
step	equ zeroPageLocal+11
error	equ zeroPageLocal+12
nx		equ zeroPageLocal+14
ny		equ zeroPageLocal+15

draw_init lda >bufScreen0 ; makey
 sta aux
 sta tabys
 clc
 lda #$0
 sta tabym
 ldy #1

_y clc
 adc #size
_y0 sta tabym,y
 tax
 bcc _y22
 inc aux
 lda aux
 sta tabys,y
 clc
_y22 lda aux
 sta tabys,y
 txa
 iny
 cpy #100
 bne _y23
 lda >bufScreen0
 clc
 adc #$10
 sta aux
 lda #0
 beq _y0 ;!
_y23 cpy #0 
 bne _y
 rts


draw 
 ldx #1
 stx dx
 stx dy
 dex
 stx ax
 stx ay
 stx error+1
 stx adr+1
 lda x2
 cmp x1
 bcs jmp0
 ldy x1
 sty x2
 sta x1
 lda y1
 ldy y2
 sty y1
 sta y2
 lda x2
 sec
jmp0 sbc x1
 sta nx
 sta step
 lda y2
 cmp y1
 bcs jmp1
 lda y1
 sec
 sbc y2
 sta ny
 ldy #255
 sty dy
 bmi jmp2
jmp1 sbc y1
 sta ny
jmp2 lda nx
 cmp ny
 bcs jmp3
 ldy ny
 sty nx
 sty step
 sta ny
 lda dy
 sta ax
 stx dx
 stx dy
 inx
 stx ay

jmp3 lda y1
 tya
 pha
 ldy y1
 lda tabym,y
 sta adr
 lda tabys,y
 sta adr+1
 pla
 tay
 lda nx
 lsr @
 sta error
 inc step
 lda dx
 bne rozw
 lda ax
 bmi aaa1
 jmp aaa4
rozw lda dy
 bmi aaa2
 bpl aaa3
aaa1 jsr putp
 sec
 lda adr
 sbc #size
 sta adr
 bcs *+4
 dec adr+1
 lda error
 clc
 adc ny
 sta error
 bcc nc11
 inc error+1
 clc
nc11 lda error+1
 bmi ok1
 bne mn1
 lda nx
 cmp error
 bcs ok1
mn1  inc x1
 sec
 lda error
 sbc nx
 sta error
 bcs ok1
 dec error+1
ok1 dec step
 bne aaa1
 rts
aaa2 jsr putp
 inc x1
 clc
 lda error
 adc ny
 sta error
 bcc nc12
 inc error+1
nc12 lda error+1
 bmi ok2
 bne mn2
 lda nx
 cmp error
 bcs ok2
mn2  sec
 lda adr
 sbc #size
 sta adr
 bcs *+5
 dec adr+1
 sec
 lda error
 sbc nx
 sta error
 bcs ok2
 dec error+1
ok2 dec step
 bne aaa2
 rts
aaa3 jsr putp
acc clc
 inc x1
 lda error
 adc ny
 sta error
 bcc nc13
 inc error+1
 clc
nc13 lda error+1
 bmi ok3
 bne mn3
 lda nx
 cmp error
 bcs ok3
mn3 lda adr
 adc #size
 sta adr
 bcc *+4
 inc adr+1
 sec
 lda error
 sbc nx
 sta error
 bcs ok3
 dec error+1
ok3 dec step
 bne aaa3
 rts
aaa4 jsr putp
 clc
 lda adr
 adc #size
 sta adr
 bcc *+5
 inc adr+1
 clc
 lda error
 adc ny
 sta error
 bcc nc14
 inc error+1
nc14 lda error+1
 bmi ok4
 bne mn4
 lda nx
 cmp error
 bcs ok4
mn4 inc x1
 sec
 lda error
 sbc nx
 sta error
 bcs ok4
 dec error+1
ok4 dec step
 bne aaa4
 rts

putp lda x1
 tay
 lda #$fe
 sta (adr),y
 rts


.endp
