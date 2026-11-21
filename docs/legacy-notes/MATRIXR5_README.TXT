MATRIXR5 — PROGRESSIVE BLANK RAIN
TRS-80 MODEL III / LDOS 5.1 / Z80

New behaviour: after about 5–10 seconds of ordinary Matrix rain, the same falling streams begin drawing ASCII 32 (space) instead of visible glyphs. They gradually erase existing characters only where the falling blanks pass. The display is NOT cleared at the moment the phase changes.

After about 5–10 more seconds, visible rain resumes. The cycle repeats until any key is pressed. Times are approximate and based on animation frames.

To install, copy MATRIXR5.CMD to a TRS-80 disk as MATRIXR5/CMD. At LDOS READY type MATRIXR5. Press any key to exit.

Preserved: extended special symbols, lowercase, variable falling speeds, and exclusions of full block (191), period (46), colon (58) and semicolon (59). Blank character 32 is intentionally allowed.

The code passed assembly/binary consistency checks; this release has not yet been tested on physical hardware.
