	processor 6502
	seg code
	org $F000	; defines the code origin at $F000

Start:
	sei		; disables the interrupts
	cld		; disable the BCD decimal math mode
	ldx #$FF 	; loads the X register with #$FF
	txs		; transfer X register to the Stack register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CLear the zero page region ($00 to $FF)
; Meaning the entire TIA regsiter space and also RAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #0		; A = 0
	ldx #$FF	; X = $FF
	sta $FF ; storing the value zero at $FF before starting the loop
MemLoop:
	dex				; x--
	sta $0,X	; store A register at address $0 + X
	bne MemLoop	; loop until X==0 (z-flag set)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill ROM Size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org $FFFC
	.word Start	; reset vector at $FFFC (where program starts)
	.word Start	; Interrupt vector at $FFFE (unused in VCS)
