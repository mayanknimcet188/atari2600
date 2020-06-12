    processor 6502

    include "vcs.h"
    include "macro.h"

    seg
    org $f000

Reset:
    CLEAN_START

    ldx #$80    ;blue background color
    stx COLUBK  ;set backgorund color Blue

    lda #$1C    ;yellow playfield color
    sta COLUPF  ;set yellow playfield

StartFrame:
    lda #02
    sta VBLANK
    sta VSYNC

    REPEAT 3
      sta WSYNC
    REPEND

    lda #0
    sta VSYNC

    REPEAT 37
      sta WSYNC
    REPEND
    lda #0
    sta VBLANK


    ldx #%00000001 ;(CTRLPF) set to reflect as D0 is set to 1
    stx CTRLPF

    ldx #0
    stx PF0
    stx PF1
    stx PF2

    REPEAT 7
      sta WSYNC
    REPEND


    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2

    REPEAT 7
      sta WSYNC
    REPEND

    ldx #%01100000
    stx PF0
    ldx #%00000000
    stx PF1
    ldx #%10000000
    stx PF2

    REPEAT 164
      sta WSYNC
    REPEND

    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2

    REPEAT 7
      sta WSYNC
    REPEND

    ldx #0
    stx PF0
    stx PF1
    stx PF2

    REPEAT 7
      sta WSYNC
    REPEND

    lda #2
    sta VBLANK
    REPEAT 30
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK

    jmp StartFrame

    org $fffc
    .word Reset
    .word Reset
