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
JetXPos               byte       ;player 0 x-position
JetYPos               byte       ;player 0 y-position
BomberXPos            byte       ;player 1 x-position
BomberYPos            byte       ;player 1 y-position
JetSpritePtr          word       ;pointer to player 0 sprite lookup table
JetColorPtr           word       ;pointer to player0 color lookup table
BomberSpritePtr       word       ;pointer to player1 sprtie look up table
BomberColorPtr        word       ;pointer to player1 color lookup table

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

    lda #83
    sta BomberYPos    ;BomberYPos = 83

    lda #54
    sta BomberXPos    ;BomberXPos = 54

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Initialize pointer to the correct lookup table addresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #<JetSprite
    sta JetSpritePtr    ;lo-byte ptr for jet sprite lookup table
    lda #>JetSprite
    sta JetSpritePtr+1  ;hi-byte pointer for jetsprtie lookup table

    lda #<BomberSprite    ;lo-byte ptr for bomber sprite lookup table
    sta BomberSpritePtr
    lda #>BomberSprite    ;hi-byte ptr for bomber sprite lookup table
    sta BomberSpritePtr+1

    lda #<BomberColor
    sta BomberColorPtr    ;lo-byte for bomber color pointer lookup table
    lda #>BomberColor
    sta BomberColorPtr+1  ;hi-byte for bomber color pointer lookup table

    lda #<JetColor
    sta JetColorPtr    ;lo-byte ptr for jet color lookup table
    lda #>JetColor
    sta JetColorPtr+1  ;hi-byte pointer for jet color lookup table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Deefine Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JET_HEIGHT = 9      ;player sprite hegiht (9 rows in lookup table)
BOMBER_HEIGHT = 9   ;bomber sprite height (9 rows in lookup table)
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
;; Display the 96 visible scanlines of our main game (because 2-line kernel)
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

    ldx #96        ;X reg acting as a scanline counter for 2-line kernel
.GameLineLoop:
.AreWeInsideJetSprite:
    txa                    ;transfer X to accumulator
    sec                    ;make sure the carry flag is set before subtraction
    sbc JetYPos            ;subtraction sprite Y cordinnate
    cmp JET_HEIGHT         ;are we inside the sprite
    bcc .DrawSpriteP0      ;if result < sprtie height, call the draw routine
    lda #0                  ; else set lookup index to zero
.DrawSpriteP0:
    tay                     ;transfer accumulator to Y, so we can work with pointer as it is only availavle for Y register
    lda (JetSpritePtr),Y    ;load player 0 bitmap data from lookup table
    sta WSYNC               ;wait for next scanline
    sta GRP0                ;set graphics for player 0
    lda (JetColorPtr),Y     ;load player color from lookup table
    sta COLUP0              ;set color of player 0

.AreWeInsideBomberSprite:
    txa                    ;transfer X to accumulator
    sec                    ;make sure the carry flag is set before subtraction
    sbc BomberYPos            ;subtraction sprite Y cordinnate
    cmp BOMBER_HEIGHT         ;are we inside the sprite
    bcc .DrawSpriteP1      ;if result < sprtie height, call the draw routine
    lda #0                  ; else set lookup index to zero
.DrawSpriteP1:
    tay                   ; ;transfer accumulator to Y, so we can work with pointer as it is only availavle for Y register
    lda #%00000101
    sta NUSIZ1                ;streching the bobmer sprite to make it look big in size                  
    lda (BomberSpritePtr),Y    ;load player 0 bitmap data from lookup table
    sta WSYNC               ;wait for next scanline
    sta GRP1                ;set graphics for player 0
    lda (BomberColorPtr),Y     ;load player color from lookup table
    sta COLUP1              ;set color of player 0


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Lookup table for sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JetSprite:
        .byte #%00000000
        .byte #%00010100
        .byte #%01111111
        .byte #%00111110
        .byte #%00011100
        .byte #%00011100
        .byte #%00001000
        .byte #%00001000
        .byte #%00001000
;JET_HEIGHT = . - JetSprite another approach
JetSpriteTurn:
        .byte #%00000000
        .byte #%00001000
        .byte #%00111110
        .byte #%00011100
        .byte #%00011100
        .byte #%00011100
        .byte #%00001000
        .byte #%00001000
        .byte #%00001000
BomberSprite:
        .byte #%00000000
        .byte #%00001000
        .byte #%00001000
        .byte #%00101010
        .byte #%00111110
        .byte #%01111111
        .byte #%00101010
        .byte #%00001000
        .byte #%00011100
JetColor:
        .byte #$00;
        .byte #$18;
        .byte #$0A;
        .byte #$0E;
        .byte #$0E;
        .byte #$02;
        .byte #$B6;
        .byte #$0E;
        .byte #$08;
JetColorTurn:
        .byte #$00;
        .byte #$18;
        .byte #$0A;
        .byte #$0E;
        .byte #$0E;
        .byte #$02;
        .byte #$B6;
        .byte #$0E;
        .byte #$08;

BomberColor:
        .byte #$00;
        .byte #$22;
        .byte #$22;
        .byte #$0E;
        .byte #$20;
        .byte #$20;
        .byte #$20;
        .byte #$20;
        .byte #$20;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill our ROM cartridge with exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Reset       ;write two bytes wit hthe programme reset addreess
    .word Reset       ;write 2 bytes for interruption routine
