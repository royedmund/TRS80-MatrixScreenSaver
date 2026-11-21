; MATRIXF2 - Extended-character Matrix rain without block/dot/colon/semicolon for the TRS-80 Model III
; 64 x 16; 48K Model III; LDOS 5.1; lower-case and special ROM glyphs
; Load as MATRIXF2/CMD and type MATRIXF2 at LDOS READY.
; Press ANY KEY to return to DOS. Uses current Model III character ROM bank.
; Original implementation, 21 November 2026. Monochrome only.
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
        LD IY,LENGTHS
        LD B,64
INIT:
        CALL RAND
        AND 15
        OR 240              ; stagger initial head, -16 through -1
        LD (IX+0),A
        CALL RAND
        AND 7
        ADD A,9             ; trail length 9..16
        LD (IY+0),A
        INC IX
        INC IY
        DJNZ INIT
WAIT_RELEASE:
        LD A,(38FFh)
        OR A
        JR NZ,WAIT_RELEASE    ; ignore ENTER key used to start program

FRAME:
        LD IX,HEADS
        LD IY,LENGTHS
        LD E,0               ; screen column 0..63
        LD B,64
COLUMN:
        CALL RAND
        AND 3
        JP NZ,NEXT          ; varied individual column speeds
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
        LD C,217             ; alternate ROM symbol instead of full block
        CALL PUTCHAR
NO_HEAD:
        LD A,(IX+0)
        SUB 4
        JP C,NO_FADE1
        CP 16
        JP NC,NO_FADE1
        LD D,A
        LD C,202             ; alternate ROM symbol, no colon
        CALL PUTCHAR
NO_FADE1:
        LD A,(IX+0)
        SUB 7
        JP C,NO_FADE2
        CP 16
        JP NC,NO_FADE2
        LD D,A
        LD C,248             ; alternate ROM symbol, no period
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
        AND 15
        OR 240              ; stagger next fall
        LD (IX+0),A
        CALL RAND
        AND 7
        ADD A,9
        LD (IY+0),A
NEXT:
        INC IX
        INC IY
        INC E
        DEC B
        JP NZ,COLUMN

        LD A,(38FFh)        ; any key depressed?
        OR A
        JP NZ,DONE
        LD BC,1800          ; animation speed: adjust to taste
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

; Generate a Model III video RAM character in C.
; Approx: 50% special 192..255, 25% lowercase, 12.5% uppercase,
; 6.25% ASCII @.._, 3.125% graphics (even 128..190), 3.125% ROM codes 0..31.
; NEVER generates video codes 46 (.), 58 (:), 59 (;), or 191 (full block).
; The active alternate character bank is set by the machine, not here.
; 192..255 bypass BASIC's space-compression output conventions.
RANDCHAR:
        CALL RAND
        BIT 7,A
        JP NZ,RC_SPECIAL
        BIT 6,A
        JP NZ,RC_LOWER
        BIT 5,A
        JP NZ,RC_UPPER
        BIT 4,A
        JP NZ,RC_ASCII
        BIT 3,A
        JP NZ,RC_GRAPH
RC_SYMBOL:
        CALL RAND
        CALL RAND
        CALL RAND
        CALL RAND           ; decorrelate dispatch bits from symbol choice
        AND 31
        LD C,A
        RET
RC_GRAPH:
        CALL RAND
        CALL RAND
        CALL RAND
        CALL RAND           ; decorrelate dispatch bits from graphic choice
        AND 62              ; even semigraphic codes 128..190, never full block 191
        OR 128
        LD C,A
        RET
RC_SPECIAL:
        CALL RAND
        AND 63
        OR 192
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
RC_UPPER:
        CALL RAND
        AND 31
        CP 26
        JP NC,RC_UPPER
        ADD A,65
        LD C,A
        RET
RC_ASCII:
        CALL RAND
        CALL RAND
        CALL RAND
        CALL RAND           ; decorrelate symbol selection
        AND 31              ; 0..31
        OR 64               ; @ through _, excludes period, colon, semicolon
        NOP                 ; padding to preserve executable offsets
        NOP
        NOP
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
LENGTHS: DS 64
        END START
