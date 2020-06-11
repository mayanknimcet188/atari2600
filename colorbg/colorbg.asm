    processor 6502
    include "vcs.h"
    include "macro.h"

    seg code
    org $F000   ;defines the origin of the ROM at $F000
START:
    CLEAN_START ;Macro to safely clear the memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Set background color to yellow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$1E    ;load color into A (yellow)
    sta COLUBK    ;set the background color to yellow

    jmp START     ;Repeat from CLEAN_START

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill rom size to exaclty 4k
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  org $FFFC   ;Defines oriign at $FFFC
  .word START     ;Reset vector at $FFFC (Where program starts)
  .word START       ;Interrupt vector at $FFFE
