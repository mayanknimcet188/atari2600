    processor 6502
    include "vcs.h"
    include "macro.h"

    seg code
    org $f000
Start:
    CLEAN_START         ;macro to safely clear TIA and memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by turning on VBALNK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NextFrame:
    lda #2      ;same as %00000010 binary
    sta VBLANK  ;turn on VBLANK
    sta VSYNC   ;turn on VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Genretate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC     ;first scanline
    sta WSYNC     ;second scanline
    sta WSYNC     ;third scanline

    lda #0
    sta VSYNC   ;turn off VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the 37 scanlines of vertical VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37     ; to count 37 scanlines
LoopVBLank:
    sta WSYNC   ; hit WSYNC and wait for the next scanlines
    dex         ;x--
    bne LoopVBLank    ;loop until x!=0

    lda #0
    sta VBLANK    ;turn off LoopVBLank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render the actual visible  192 scanlines (kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #192
LoopVisible:
    stx COLUBK    ;set the background color
    sta WSYNC      ;wait for the next scanlines
    dex           ; x--
    bne LoopVisible ; loop until x!=0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output 30 more VBLANK Lines to complete our Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK

    ldx #30
LoopOverScan:
    sta WSYNC     ;wait for the next scanlines
    dex           ;x--
    bne LoopOverScan


    jmp NextFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complte the ROM size to 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $fffc
    .word Start
    .word Start
