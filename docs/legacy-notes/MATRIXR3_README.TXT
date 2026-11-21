MATRIXR3 - LAYERED MATRIX RAIN FOR TRS-80 MODEL III
==================================================
Built 21 November 2026 for a Model III with 48K RAM, lower case and
alternate character ROM support. Runs under LDOS 5.1 on the user's
working Model III hardware, subject to physical testing.

FILES
  MATRIXR3.CMD       Native TRS-80 Z80 machine code (/CMD) executable
  MATRIXR3.ASM       Z80 source, assembled at 6000h
  MATRIXR3.BAS       Slower interpreted BASIC counterpart (ASCII text)
  MATRIXR3_README.TXT

INSTALL & RUN
  Import MATRIXR3.CMD into a TRS-80 disk image as MATRIXR3/CMD.
  At LDOS READY, enter:

      MATRIXR3

  Press any key to clear the screen and return to LDOS.
  The program waits for the launching ENTER key to be released.

IMPROVEMENTS OVER MATRIXF2
  - 64 independent streams with speeds of 1, 2, 3, or 4 frames per step
  - speed remains consistent for a given fall, changes on restart
  - variable stream length (7-22 characters) and initial vertical position
  - randomised special-character leading glyph rather than a solid block
  - several re-randomised characters behind each head
  - occasional gaps inside each column, increasingly sparse at the tail
  - glyph selection mostly from the active 192-255 Model III special bank
  - remaining glyphs mostly lower-case text, digits, and thin semigraphics
  - no character codes 191 (full block), 46 (.), 58 (:), or 59 (;)

SPECIAL CHARACTER BANK
  This writes video RAM directly at 3C00h-3FFFh; it does not switch
  Model III character banks. The active special/Katakana ROM selection
  and your CRT's phosphor determine the appearance. The Model III does
  not offer multiple foreground colours or per-character brightness.

TUNING
  In MATRIXR3.ASM change 'LD BC,1150' near DELAY to alter the
  overall speed: 700 is faster, 1800 is slower. Reassemble to apply.
  The per-column speed range is set by 'AND 3 / INC A' (1..4).
  The assembly source is plain text and intended for Z80 assemblers;
  their exact ORG/DS/END syntax may vary.

  MATRIXR3.BAS is plain text. It is not a tokenised BASIC disk file.
  Enter into LDOS LBASIC or import via a BASIC conversion utility.
  In BASIC the effect is much slower because it is interpreted.

SAFETY & VALIDATION
  Uses RAM 6000h onward, video RAM 3C00h-3FFFh, keyboard matrix
  38FFh. No floppy writes. The /CMD file has proper block records and
  a 6000h execution record. Its assembler was verified byte-for-byte
  by reproducing the previous known-working MATRIXF2/CMD. This new
  variant has NOT yet been run on the user's physical Model III.

  Keep your existing MATRIXF2/CMD or MATRIXFX/CMD as a backup.

SOURCE REFERENCES
  https://en.wikipedia.org/wiki/TRS-80_character_set
  https://www.youtube.com/watch?v=95rAM5LkZ2w
  https://www.youtube.com/watch?v=liFjsSDj1eM
