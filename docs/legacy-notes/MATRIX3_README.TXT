MATRIX3 - MATRIX-STYLE CHARACTER RAIN FOR THE TRS-80 MODEL III
Version 1.0 (21 November 2026)

CONTENTS
--------
MATRIX3.CMD   Native Z80 machine code in TRS-80 DOS /CMD format (451 bytes)
MATRIX3.ASM   Readable Z80 assembly source
MATRIX3.BAS   TRS-80 BASIC version (ordinary ASCII text listing)

WHAT IT DOES
------------
Recreates the idea of the falling-character Matrix screensaver on a
monochrome TRS-80 Model III's 64x16 display. Each column has its own
falling head and trail. Alphabetic/numeric glyphs are brightest near
the head, then fade to colons and dots before disappearing.

Because the Model III does not have colour graphics, the 'green' look
of the original screensaver depends on the colour of your CRT or monitor.
The solid block leading character uses Model III semigraphics code 191.

Z80 /CMD VERSION (recommended for smooth animation)
----------------------------------------------------
1. Copy/import MATRIX3.CMD into a TRS-80 disk image or onto an LDOS,
   TRSDOS, or NEWDOS/80-compatible disk as the file MATRIX3/CMD.
   A PC-host .CMD file isn't itself a whole floppy disk image: you need
   your regular emulator/disk-image file-transfer tool to put it on disk.
2. Boot a DOS on the Model III; at DOS READY type:

       MATRIX3

3. Press ANY key to stop and return to DOS READY.

The program loads at 6000h and jumps to the standard DOS return at
402Dh on exit. Its code and data occupy well under 1K of RAM. It
writes directly to screen RAM 3C00h-3FFFh. The keyboard matrix is
sampled at 38FFh. Interrupts are left enabled.

BASIC VERSION (slower, easy to customise)
-----------------------------------------
1. Boot TRSDOS or LDOS and enter its disk BASIC, or use Model III BASIC.
2. Type the numbered listing in MATRIX3.BAS, or import it as an ASCII
   BASIC program using your preferred disk-image tool. If using text
   import, ensure the lines are accepted as BASIC source, not merely as
   an ordinary /TXT data file.
3. RUN the program. Press any key to end it.

NOTE: MATRIX3.BAS is a text listing, not a tokenised BASIC file or a
cassette recording. It is provided for inspection, typing and import.

TUNING
------
In the BASIC listing:
  line 90   RND(3) makes each column advance about one-third of passes.
            Change to RND(2) for faster motion.
  line 60   RND(16) changes initial head delays.
  line 160  RND(16) changes new drop delays.

In MATRIX3.ASM:
  change LD BC,1800 for faster/slower animation, then assemble again.
  Smaller delay count means faster animation.

VERIFICATION / LIMITS
---------------------
The .CMD file was assembled as genuine Z80 machine instructions and its
CMD records and load/transfer addresses were checked independently.
Its drawing and keyboard-exit routines were exercised in a small
software Z80 instruction simulator, including video RAM boundaries and
its return to 402Dh. It has NOT been physically tested on a Model III
or with a full TRS-80 emulator; please treat it as a first release.

The program is original and not copied from any Matrix screensaver.
