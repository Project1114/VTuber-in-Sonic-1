; ---------------------------------------------------------------------------
; Align and pad
; input: length to align to, value to use as padding (default is 0)
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; Set a VRAM address via the VDP control port.
; input: 16-bit VRAM address, control port (default is ($C00004).l)
; ---------------------------------------------------------------------------

locVRAM:	macro loc,controlport
		if (narg=1)
		move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),($C00004).l
		else
		move.l	#($40000000+((loc&$3FFF)<<16)+((loc&$C000)>>14)),controlport
		endc
		endm

torsoart = $7A0 ($C tiles)
headart = $7AC ($14 tiles)
hairart = $798 (8 tiles)
ringart = $6BA ($E tiles)
pointsart = $568 (9 tiles)
lamppostart = $571 ($A tiles)

ssringart = $22D ($E tiles)

SonimeSST = $FFFFF5C0
v_ssangleprev = $FFFFFFF9
FromSEGA = $FFFFF601

sonime_headtimer = 0
sonime_headx = 2
sonime_heady = 3
sonime_routine = 4
sonime_routine2 = 5
sonime_headx2 = 6
sonime_headx3 = 7
sonime_hairx = 9
sonime_heady2 = $A
sonime_heady3 = $B
sonime_hairy = $D
sonime_face = $E
sonime_faceold = $F
sonime_facetimer = $10
sonime_ear = $12
sonime_earold = $13
sonime_eartimer = $14
sonime_torsox = $16
sonime_movein = $17
sonime_waittimer = $18
sonime_waittimer2 = $19
sonime_pausetimer = $20
sonime_airtimer = $22

face_neutrall = 0
face_blink = 1
face_neutrallm = 2
face_neutralm = 3
face_neutralr = 4
face_frustrated = 5
face_surprised = 6
face_happy = 7
face_confused = 8
face_meltdown = 9
face_panic = $A
face_impatient = $B

; ===========================================================================
; ---------------------------------------------------------------------------
; Macros
; ---------------------------------------------------------------------------

	; --- Alignment ---

align		macro	Size,Value
		dcb.b	Size-(*%Size),Value
		endm

	; --- Stop Z80 ---

StopZ80		macro
		move.w	#$0100,($A11100).l			; request Z80 stop (ON)
		btst.b	#$00,($A11100).l			; has the Z80 stopped yet?
		bne.s	*-$08					; if not, branch
		endm

	; --- Start Z80 ---

StartZ80	macro
		move.w	#$0000,($A11100).l			; request Z80 stop (OFF)
		endm

	; --- Turning DMA mode on ---

Z80DMA_ON	macro
		StopZ80
		move.b	#(Flush&$FF),($A00000+FL_FlushSwitch+1).l	; change the "jp" instruction address to "Flush" routine loop
		StartZ80
		move.w	#$0180,d7				; set delay time (give z80 time to get out of the "CatchUp" routine...
		nop						; ...and into the "Flush" routine, so the 68k doesn't start DMA before...
		nop						; ...the z80 has a chance to stop reading from the window
		dbf	d7,*-$04				; loop back and perform the nops again...
		endm

	; --- Turning DMA mode off ---

Z80DMA_OFF	macro
		StopZ80
		move.b	#(CatchUp&$FF),($A00000+FL_FlushSwitch+1).l	; change the "jp" instruction address to "CatchUp" routine loop
		StartZ80
		endm


	; --- Storing 68k address for Z80 as dc ---

dcz80		macro	Sample
		dc.b	(Sample&$FF)
		dc.b	(((Sample>>$08)&$7F)|$80)
		dc.b	((Sample&$7F8000)>>$0F)
		endm

; ===========================================================================