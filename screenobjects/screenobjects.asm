    processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include required files with definitions and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    include "vcs.h"
    include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start an uninitializzed segment at $80 variable declaration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80
P0Height ds 1     ;defines one byte for player 0 height
P1Height ds 1     ;defines one byte for player 1 height


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start our ROM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg
    org $f000

Reset:
    CLEAN_START

    ldx #$80      ;blue background color
    stx COLUBK

    lda #%1111    ;white playfield color
    lda COLUPF
    lda #10       ;A=10
    sta P0Height  ;P0Height = 10
    sta P1Height  ;P1Hegiht = 10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; We set the TIA registers for the color of P0 and P1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$48    ;player 0 color light red
    sta COLUP0

    lda #$C6    ;light green for P1
    sta COLUP1

    ldy #%00000010 ;CTRL D1 set t o1 means (score)
    sty CTRLPF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new Frame by configuring VSYNC and VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Draw the 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VisibleScanlines:
    ;10 empty scanlines at the top of the Frame
    REPEAT 10
      sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Displays 10 scanlines for the scoreboard number
;; Pulls data for an array of bytes defined at NUmberBitmap.
    ldy #0
ScoreboardLoop:
    lda NUmberBitmap,Y
    sta PF1
    sta WSYNC
    iny
    cpy P0Height
    bne ScoreboardLoop

    lda #0
    sta PF1 ;disavle playfield

    ;Draw 50 empty scanlines between scoreboard and player
    REPEAT 50
      sta WSYNC
    REPEND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display 10 lines for the Player 0 character graphics
;;Pulls data from an array of bytes defined at Playerbitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldy #0
Player0Loop:
    lda Playerbitmap,Y
    sta GRP0
    sta WSYNC
    iny
    cpy P1Height
    bne Player0Loop

    lda #0
    sta GRP0    ;diable player 0 graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Diplays 10 scanlines for player 1 graphics.
;; Pulls data from an array of bytes defined at Playerbitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldy #0
Player1Loop:
    lda Playerbitmap,Y
    sta GRP1
    sta WSYNC
    iny
    cpy #10
    bne Player1Loop

    lda #0
    sta GRP1    ;diable player 1 graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw the remaining 102 scanlines (192-90) since we already
;; used 10+10+50+10+10 = 90 scanlines in the current frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 102
      sta WSYNC
    REPEND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Output the 30 VBLANK overscan lines to complete the Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 30
      sta WSYNC
    REPEND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop to the next Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Defines an array of bytes to draw the scoreboard NUmberBitmap
;; We add these bytes to the Final ROM addresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFE8
Playerbitmap:
    .byte #%01111110      ; ######
    .byte #%11111111      ;########
    .byte #%10011001      ;#  ##  #
    .byte #%11111111      ;########
    .byte #%11111111      ;########
    .byte #%11111111      ;########
    .byte #%10111101      ;# #### #
    .byte #%11000011      ;##    ##
    .byte #%11111111      ;########
    .byte #%01111110      ; ######

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Defines an array of bytes to draw the scoreboard NUmber
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFF2
NUmberBitmap:
    .byte #%00001111            ; ########
    .byte #%00001111            ; ########
    .byte #%00000001            ;      ###
    .byte #%00000001            ;      ###
    .byte #%00001111            ; ########
    .byte #%00001111            ; ########
    .byte #%00001000            ; ###
    .byte #%00001000            ; ###
    .byte #%00001111            ; ########
    .byte #%00001111            ; ########
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill the ROM exaclty to 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Reset
    .word Reset
