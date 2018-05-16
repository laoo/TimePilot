
;hardware

KEY_ESC   equ $1c

trig0	  equ $d010 ; joy0 fire 

colpm0	  equ $d012 ; 704
colpm1    equ $d013
colpm2    equ $d014
colpm3    equ $d015

colpf0    equ $d016 ; 708
colpf1    equ $d017 
colpf2    equ $d018
colpf3    equ $d019
colbak    equ $d01a
gtiactl   equ $d01b

consol 	  equ $d01f 

audc1	  equ $d201
audc2	  equ $d203
audc3	  equ $d205
audc4	  equ $d207

kbcode    equ $d209
random    equ $d20a
irqen     equ $d20e
irqst     equ $d20e
skstat    equ $d20f

porta     equ $d300
portb     equ $d301

dmactl    equ $d400
dlptr     equ $d402
vcount    equ $d40b
nmien     equ $d40e
nmist     equ $d40f
wsync     equ $d40a

;solo
; SCROLLS
hscrol equ $d404
; FONTS
chbase equ $d409
; P/M
pmbase equ 54279
pmactive equ 53277
sizep0 equ 53256
sizep1  equ 53257
sizep2 equ 53258
sizep3 equ 53259
sizem equ 53260
hposp0 equ 53248
hposp1 equ 53249
hposp2 equ 53250
hposp3 equ 53251
hposm0 equ 53252
hposm1 equ 53253
hposm2 equ 53254
hposm3 equ 53255
kolm0p equ $d008
kolm1p equ $d009
kolm2p equ $d00a
kolm3p equ $d00b
hitclr equ $d01e

