; MATRIXR3 - Layered falling Matrix streams without block/dot/colon/semicolon for the TRS-80 Model III
; 64 x 16; 48K Model III; LDOS 5.1; lower-case and special ROM glyphs
; Load as MATRIXR3/CMD and type MATRIXR3 at LDOS READY.
; Press ANY KEY to return to DOS. Uses current Model III character ROM bank.
; Improved layered-rain variant, 21 November 2026. Monochrome only.
; Column state: LENGTH (0), COUNTDOWN (1), SPEED (2).
;
; TRS-80 hardware addresses:
;   VIDEO = 3C00h .. 3FFFh   64 x 16 display
;   KEYBD = 38FFh            OR of 8 keyboard matrix rows
;   EXIT  = 402Dh            standard DOS command exit (@EXIT)
;
        ORG 6000h
START:
        CALL CLEAR
        LD IX,HEADS
        LD IY,STATES
        LD B,64
INIT:
        CALL RAND
        AND 31
        SUB 14              ; start positions -14 through 17
        LD (IX+0),A
        CALL RAND
        AND 15
        ADD A,7             ; trail length 7..22
        LD (IY+0),A
        CALL RAND
        AND 3
        INC A               ; speed 1-4 animation frames / character
        LD (IY+1),A        ; countdown
        LD (IY+2),A        ; speed
        INC IX
        INC IY
        INC IY
        INC IY
        DJNZ INIT
WAIT_RELEASE:
        LD A,(38FFh)
        OR A
        JR NZ,WAIT_RELEASE    ; ignore ENTER key used to start program

FRAME:
        LD IX,HEADS
        LD IY,STATES
        LD E,0               ; screen column 0..63
        LD B,64
COLUMN:
        LD A,(IY+1)
        DEC A
        LD (IY+1),A
        JP NZ,NEXT          ; each column has its own fixed speed
        LD A,(IY+2)
        LD (IY+1),A
        LD A,(IX+0)
        BIT 7,A
        JP NZ,ADVANCE       ; column has not yet entered screen
        OR A
        JR Z,NO_PREV
        DEC A
        CP 16
        JR NC,NO_PREV
        LD D,A               ; prior head row
        CALL RANDCHAR        ; current character set, weighted to pseudo-Kana
        CALL PUTCHAR
NO_PREV:
        LD A,(IX+0)
        SUB 2
        JP C,NO_SECOND
        CP 16
        JP NC,NO_SECOND
        LD D,A
        CALL RANDCHAR        ; second flowing code glyph
        CALL PUTCHAR
NO_SECOND:
        LD A,(IX+0)
        SUB 3
        JP C,NO_THIRD
        CP 16
        JP NC,NO_THIRD
        LD D,A
        CALL RANDCHAR        ; third flowing glyph, longer code streaks
        CALL PUTCHAR
NO_THIRD:
        LD A,(IX+0)
        CP 16
        JR NC,NO_HEAD
        LD D,A
        CALL RC_SPECIAL      ; distinct pseudo-Kana leading glyph
        CALL PUTCHAR
NO_HEAD:
        LD A,(IX+0)
        SUB 4
        JP C,NO_FADE1
        CP 16
        JP NC,NO_FADE1
        LD D,A
        CALL RAND
        AND 3
        JP NZ,GAP_CHAR
        LD C,32              ; occasional hole within a falling stream
        JP GAP_DRAW
GAP_CHAR:
        CALL RANDCHAR
GAP_DRAW:
        CALL PUTCHAR
NO_FADE1:
        LD A,(IX+0)
        SUB 7
        JP C,NO_FADE2
        CP 16
        JP NC,NO_FADE2
        LD D,A
        CALL RAND
        AND 1
        JP NZ,FADE_CHAR
        LD C,32              ; sparser trailing code, implies dimness
        JP FADE_DRAW
FADE_CHAR:
        CALL RANDCHAR
FADE_DRAW:
        CALL PUTCHAR
NO_FADE2:
        LD A,(IX+0)
        SUB (IY+0)
        JP C,ADVANCE         ; tail is still above top of screen
        CP 16
        JP NC,ADVANCE
        LD D,A
        LD C,32              ; erase tail
        CALL PUTCHAR
ADVANCE:
        LD A,(IX+0)
        INC A
        LD (IX+0),A
        BIT 7,A
        JR NZ,NEXT           ; negative start offset
        LD C,A
        LD A,(IY+0)
        ADD A,16
        CP C
        JR NC,NEXT
        CALL RAND
        AND 31
        SUB 14              ; variable empty pause before new stream
        LD (IX+0),A
        CALL RAND
        AND 15
        ADD A,7
        LD (IY+0),A
        CALL RAND
        AND 3
        INC A               ; change speed on restart
        LD (IY+1),A
        LD (IY+2),A
NEXT:
        INC IX
        INC IY
        INC IY
        INC IY
        INC E
        DEC B
        JP NZ,COLUMN

        LD A,(38FFh)        ; any key depressed?
        OR A
        JP NZ,DONE
        LD BC,1150          ; frame delay, lower = faster
DELAY:
        DEC BC
        LD A,B
        OR C
        JR NZ,DELAY
        JP FRAME

DONE:
        CALL CLEAR
        JP 402Dh             ; normal return to DOS

CLEAR:
        LD HL,3C00h
        LD (HL),32
        LD DE,3C01h
        LD BC,1023
        LDIR
        RET

 ; Weighted Model III character picker.
; About 75% glyphs 192-255 (alternate character bank),
; 12.5% lower case, 6.25% digits, 3.125% upper case,
; 3.125% tiny semigraphics. Does NOT emit codes 46, 58, 59, 191.
RANDCHAR:
        CALL RAND
        BIT 7,A
        JP NZ,RC_SPECIAL
        BIT 6,A
        JP NZ,RC_SPECIAL
        BIT 5,A
        JP NZ,RC_LOWER
        BIT 4,A
        JP NZ,RC_DIGIT
        BIT 3,A
        JP NZ,RC_UPPER
RC_GRAPH:
        CALL RAND
        AND 21              ; 1-3 segment semigraphics only, never solid
        OR 128
        LD C,A
        RET
RC_SPECIAL:
        CALL RAND
        AND 63
        OR 192              ; 192..255 special symbols/Kana
        LD C,A
        RET
RC_LOWER:
        CALL RAND
        AND 31
        CP 26
        JP NC,RC_LOWER
        ADD A,97
        LD C,A
        RET
RC_DIGIT:
        CALL RAND
        AND 15
        CP 10
        JP NC,RC_DIGIT
        ADD A,48
        LD C,A
        RET
RC_UPPER:
        CALL RAND
        AND 31
        CP 26
        JP NC,RC_UPPER
        ADD A,65
        LD C,A
        RET

; 16-bit Galois pseudo-random generator, polynomial B400h.
; Preserves BC, DE, IX, IY. Returns random value in A.
RAND:
        LD HL,(SEED)
        SRL H
        RR L
        JR NC,NO_XOR
        LD A,H
        XOR 0B4h
        LD H,A
NO_XOR:
        LD (SEED),HL
        LD A,L
        XOR H               ; mix high/low bits for less correlation
        RET

; Input D=row (0..15), E=column (0..63), C=character
; Keeps BC, DE, IX, IY intact.
PUTCHAR:
        LD A,D
        SRL A
        SRL A
        ADD A,03Ch         ; H = 3Ch + row / 4
        LD H,A
        LD A,D
        AND 3
        RRCA
        RRCA               ; L = (row mod 4) * 64 + column
        ADD A,E
        LD L,A
        LD (HL),C
        RET

SEED:   DW 0ACE1h
HEADS:  DS 64
STATES: DS 192         ; 64 groups of (length, count, speed)
        END START
