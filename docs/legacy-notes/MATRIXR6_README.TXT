MATRIXR6 — ONE-SECOND PROGRESSIVE SPACE RAIN
TRS-80 MODEL III / 48 KB / LDOS 5.1 / Z80

Compared with MATRIXR5, normal characters fall for approximately
5–10 seconds (random duration), then only ASCII 32 SPACE characters
fall for approximately 1 second (38 animation frames).

The falling spaces erase ONLY the video cells they pass through.
The entire screen is NOT cleared when switching between phases.
Column speeds, positions and trail lengths continue naturally.

Copy bin/MATRIXR6.CMD to a TRS-80 disk as MATRIXR6/CMD, then
enter MATRIXR6 at LDOS READY. Press any key to exit.

The timing is frame-based rather than wall-clock accurate.
The original Z80 release's animation speed is unchanged. To adjust
the short phase, edit LD HL,38 inside SET_DURATION in the source.

Prohibits drawing code 191, 46, 58 and 59 as in earlier versions.
Extended glyph appearance depends on installed character ROM.

The Z80 program was assembled and compared with the included
binary. It has not been validated on physical Model III hardware.
