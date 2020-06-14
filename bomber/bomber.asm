    processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include required files with VCS register memory mapping for macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    include "vcs.h"
    include "macro.h"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare variables starting from memory address $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80
JetXPos       byte       ;player 0 x-position
JetYPos       byte       ;player 0 y-position
BomberXPos    byte       ;player 1 x-position
BomberYPos    byte       ;player 1 y-position


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start our ROM coe at memory address $F000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg Code
    org $F000
Reset:
    CLEAN_START         ;macro to reset memory and TIA registers


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize RAM variables and TIA register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #10
    sta JetYPos     ;JetYPos = 10

    lda #60
    sta JetXPos     ;JetXPos = 60

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start New Frame Rendering and Display Loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display VSYNC and VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK      ;turn on VBLANK
    sta VSYNC

    REPEAT 3
      sta WSYNC     ;Display 3 reccomemdeed lines of VSYNC
    REPEND

    lda #0
    sta VSYNC

    REPEAT 37
      sta WSYNC   ;Display 37 lines of VBLANK
    REPEND

    sta VBLANK      ;turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display the 192 visible scanlines of our main game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameVisibleLine:
    lda #$84        ;blue background color
    sta COLUBK      ;set blue blackground

    lda #$C2         ;green playfield color
    sta COLUPF      ;set green playfield
    lda #%00000001
    sta CTRLPF      ;set CTRLPF to reflect
    lda #$F0
    sta PF0         ;setting PF0 but pattern
    lda #$FC
    sta PF1         ;setting PF1 bit pattern
    lda #0
    sta PF2         ;setting PF2 bit pattern

    ldx #192        ;X reg acting as a scanline counter
.GameLineLoop:
    sta WSYNC
    dex                 ;X--
    bne .GameLineLoop   ;repeat next main game scanline until finished

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK
    REPEAT 30
      sta WSYNC   ;dislpay 30 reccomemdeed lines of VBLANK Overscan
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop back to Start /Reset to dislpay brand new frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame      ;continue to display the next Frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill our ROM cartridge with exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Reset       ;write two bytes wit hthe programme reset addreess
    .word Reset       ;write 2 bytes for interruption routine
