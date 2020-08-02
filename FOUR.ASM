; "Four", Atari XL/XE Intro 256B
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2020-08-01

rtclok	equ $0012
rowcrs	equ $0054
colcrs	equ $0055
oldrow	equ $005a
oldcol	equ $005b
cntr	equ $00c0
vvblkd	equ $0224
pcolr0	equ $02c0
pcolr1	equ $02c1
color2	equ $02c6
atachr	equ $02fb
hposp0	equ $d000
hposp1	equ $d001
hposp2	equ $d002
sizep0	equ $d008
sizep1	equ $d009
sizep2	equ $d00a
grafp0	equ $d00d
grafp1	equ $d00e
grafp2	equ $d00f
colpm0	equ $d012
colpm1	equ $d013
audf1	equ $d200
audc1	equ $d201
random	equ $d20a
wsync	equ $d40a
vcount	equ $d40b
xitvbv	equ $e462
osgraph	equ $ef9c
osdraw	equ $f9c2


	org $00ff-8

	; for "Lines" effect
step	.byte 1, 2, 3, 4
pos	.byte 100, 50, 10, 140


	org $2000

start	lda #$08
	jsr osgraph

	; initialization of PMG size, graphics shape, color for "Starfield",
	; and initialization of PMG size, shape for "Sierpinski triangle"
	ldx #$03
	iny		; ldy #2 is not necessary, since Y=1 after "jsr osgraph"
loopa1	lda #$00
	sta sizep0,y	; size of player 0, 1, 2
	sta color2	; background color in gr. 8
	lda #$01
	sta rtclok+2	; timer initialization for the first effect
	sta grafp0,y	; graphics shape of player 0, 1, 2
	txa
	sta pcolr0,y	; color and luminance of player 0, 1, 2
	asl
	tax
	dey
	bpl loopa1


	; ********************************
	; * "Sierpinski triangle" effect *
	; ********************************
loopb1	ldy #$02
loopb2	lda vcount
	;clc		; not necessary
	adc rtclok+2
	sta opcodb1+1
	lda random
opcodb1	and #$00
	;clc		; not necessary
	adc #$26
	sta hposp0,y
	lda vcount
	ora #$07
	sta colpm0,y
	dey
	bpl loopb2
	lda rtclok+2
	bne loopb1


	; **********************
	; * "Starfield" effect *
	; **********************
	;inc rtclok+2	; not necessary

	; initialization of positions of stars
	tay		; ldy #255
loopc1	lda random
	sta starpos,y
	dey
	bne loopc1

loopc2	lda vcount
	;sta wsync	; not necessary
	bne loopc2
	tax		; ldx #$00
loopc3	inc starpos,x
	lda starpos,x	
	ldy #$02
	sta wsync
loopc4	sta hposp0,y
	asl
	dey
	bpl loopc4
	dex
	bne loopc3
	lda rtclok+2
	bne loopc2


	; ********************
	; * "Strange" effect *
	; ********************
	inc rtclok+2
	sta hposp2
loopd1	ldy #$03
	sty sizep0	; size of player 0
	sty sizep1	; size of player 1
opcodd1	ldy #$ff
	sty grafp0	; graphics shape for player 0
	sty grafp1	; graphics shape for player 1
	lda vcount
	asl
	eor rtclok+2
	sta wsync
	sta hposp0
	sta colpm1	; color and luminance of player 1
	eor #$ff
	;clc		; not necessary
	adc #$e0
	sta hposp1
	sta colpm0	; color and luminance of player 0
	lda rtclok+2
	bne loopd1


	; ******************
	; * "Lines" effect *
	; ******************
loope1	ldx #$03
	stx atachr
loope2	lda pos,x
	clc
	adc step,x
	sta pos,x
	cmp #180
	bcs skipe1
	cmp #10
	bcc skipe1
	bcs skipe2
skipe1	lda #$ff
	eor step,x
	sta step,x
	inc step,x
skipe2	dex
	bpl loope2
	lda pos
	sta hposp1	; moving vertical bar in background
	sta colcrs
	lda pos+1
	sta rowcrs
	lda pos+2	
	sta oldrow
	lda pos+3
	sta oldcol
	jsr osdraw
	bne loope1	; infinite loop


	; VBLANK interrupt routine
vbrout	sbc rtclok+2
	sta audc1
	dec audf1
	jmp xitvbv


	; positions of stars for "Starfield" effect
starpos	equ *


	org vvblkd
	.word .adr(vbrout)


	run start