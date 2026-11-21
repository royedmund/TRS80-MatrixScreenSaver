MATRIXR4: MATRIX RAIN WITH RANDOM BLANK INTERVALS
TRS-80 MODEL III / LDOS 5.1 / 48K / LOWERCASE AND SPECIAL GLYPHS
=============================================================

WHAT IS NEW
  Normal Matrix rain runs for a pseudo-random interval of about 5-10
  seconds. Then the screen clears and streams keep falling invisibly:
  every video RAM write during this phase is ASCII space (32).
  After another independently random approximately 5-10 seconds,
  visible Matrix characters resume. This alternating effect repeats.
  Press any key to clear the screen and return to LDOS.

  The falling streams still advance while invisible. This is NOT a
  pause or lockup. The blank period is deliberately part of the effect.

FILES
  MATRIXR4.CMD    Native LDOS executable, /CMD load format
  MATRIXR4.ASM    Full Z80 source
  MATRIXR4_README.TXT  Instructions and tuning notes

INSTALLATION / OPERATION
  Place MATRIXR4.CMD on an LDOS disk image as MATRIXR4/CMD.
  At the LDOS READY prompt, type:

      MATRIXR4

  Release the ENTER key after starting it. Press any key to exit.
  MATRIXR3/CMD is not changed.

CHARACTER SET
  Uses current hardware character selection; mostly 192..255 with
  some lower-case, digits and sparse semigraphics. Never deliberately
  draws codes 191 (full block), 46 (.), 58 (:), or 59 (;).
  A normal SPACE (32) is deliberately allowed, and is the ONLY
  character drawn during the invisible phase.

TIMING
  The implementation counts screen frames, not real-time clock ticks.
  SET_DURATION chooses 200 + 3*(RAND & 63) = 200..389 frames per
  phase, then alternates visible and blank. The Model III frame rate
  depends somewhat on character density, timing settings and hardware.
  Thus the timing is APPROXIMATE, not guaranteed precisely 5-10 sec.

  To change normal/blank timing, change the 'ADD A,200' immediate
  constant in SET_DURATION and reassemble. For values 0..255, keep
  total max under 512 frames; this script deliberately handles carry.
  'LD BC,1150' after CHECK_KEY controls overall animation speed;
  a larger value slows all falling streams and lengthens both phases.

TECHNICAL
  Program starts at 6000h and writes only screen 3C00h..3FFFh
  plus its own RAM variables. Keyboard reads 38FFh and DOS exit
  uses JP 402Dh. It makes no disk writes.

TESTING
  Checked /CMD load-block framing, entry point, phase timer and
  conditional character write paths. Not yet tested on real Model III.
