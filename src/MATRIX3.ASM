; MATRIX3 - Falling-character screensaver for the TRS-80 Model III
; 64 columns x 16 rows; 48K Model III with LDOS / TRSDOS / NEWDOS/80
; Load as MATRIX3/CMD and type MATRIX3 at DOS READY.
; Press ANY KEY to return to DOS. All display characters are monochrome.
; Copyright-free original implementation, 21 November 2026.
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
        CALL RAND
        CALL RAND
        CALL RAND
        CALL RAND            ; decorrelate glyphs from speed choice
        RRCA
        RRCA
        RRCA
        AND 31
        CP 26
        JR C,LETTER
        SUB 26
        ADD A,48             ; digit 0..5
        JR PRINT_PREV
LETTER:
        ADD A,65             ; letter A..Z
PRINT_PREV:
        LD C,A
        CALL PUTCHAR
NO_PREV:
        LD A,(IX+0)
        CP 16
        JR NC,NO_HEAD
        LD D,A
        LD C,191             ; solid semigraphic block (bright head)
        CALL PUTCHAR
NO_HEAD:
        LD A,(IX+0)
        SUB 4
        JP C,NO_FADE1
        CP 16
        JP NC,NO_FADE1
        LD D,A
        LD C,58              ; colon = medium fade
        CALL PUTCHAR
NO_FADE1:
        LD A,(IX+0)
        SUB 7
        JP C,NO_FADE2
        CP 16
        JP NC,NO_FADE2
        LD D,A
        LD C,46              ; dot = faint tail
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
