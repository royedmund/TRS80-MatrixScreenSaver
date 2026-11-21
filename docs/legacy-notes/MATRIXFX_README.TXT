MATRIXFX - MATRIX RAIN WITH THE MODEL III EXTENDED CHARACTER SET
==============================================================
Version: 21 November 2026
Computer: TRS-80 Model III, 48K, lower-case/special character support
DOS: LDOS 5.1 (original MATRIX3/CMD also works; not overwritten)

FILES
-----
MATRIXFX.CMD   Loadable TRS-80 /CMD executable (588 bytes)
MATRIXFX.ASM   Complete, commented Z80 assembly-language source
MATRIXFX.BIN   Raw 572-byte memory image, starting at 6000h

RUNNING IT
----------
1. Copy/import MATRIXFX.CMD to a writable LDOS disk as MATRIXFX/CMD.
2. Boot LDOS and enter the command:

       MATRIXFX

3. Press ANY key to stop and return to DOS. The program waits for
   the ENTER key used to launch it to be released before starting.

WHAT IT DOES
------------
* Uses the full 64x16 Model III text screen, writing directly to video
  RAM at 3C00h..3FFFh.
* Uses all the Model III character categories:
      0..31   ROM symbols written directly into screen RAM
      32..127 All printable ASCII/punctuation, digits, and letters
      128..191 Model III 2x3 semigraphics (six-block characters)
      192..255 Special / alternate-character ROM glyphs
* All 256 byte values are selectable; character selection is weighted
  to favour 192..255 so the effect
  is more like the mysterious, pseudo-Katakana Matrix screen.
* Uses a full-block leading character, three refreshed character
  positions behind it, punctuation fade, and an erased tail.
* Independently varying stream lengths, positions, and speed.

CHARACTER-ROM CONSIDERATIONS
----------------------------
MATRIXFX uses whichever special-character ROM bank your machine
currently exposes. It does not switch character banks or modify
video mode control ports, avoiding changes to LDOS's video setup.
Characters 192..255 may look different on different Model III ROMs,
and the original hardware remains monochrome: there is no per-character
green colour or brightness control. 128..191 appear as semigraphics.

TUNING
------
The assembly source uses a delay near the end of the main loop:

       LD BC,1800

Smaller number = faster animation; larger number = slower.
Modify and reassemble if desired.

ASSEMBLY AND TEST STATUS
------------------------
The compiled executable uses standard TRS-80 /CMD load records and
runs from 6000h. It checks keyboard matrix 38FFh for exit and jumps
to LDOS/TRSDOS DOS return entry 402Dh. It does not modify the disk.

The program passed local /CMD structural checks and a software Z80
instruction simulation including screen writes and exit. It has NOT
been tested on your physical machine. Keep MATRIX3/CMD as a fallback.

Enjoy the falling code!
