# Installation

For a 48 KB TRS-80 Model III running LDOS 5.1, transfer `bin/MATRIXR5.CMD` into a TRS-80 disk or emulator disk image as `MATRIXR5/CMD`. At the `LDOS READY` prompt enter:

```text
MATRIXR5
```

Release the Enter key and press any key to exit. The program draws directly into 64×16 video RAM starting at `3C00h`, polls the keyboard at `38FFh`, and returns to DOS via `402Dh`.

MATRIXR5 has alternating approximately 5–10 second phases: visible rain and falling blank (space) characters that progressively erase the previous code. It does **not** clear the screen when changing modes; the screen clears only at startup and exit.

For speed changes, edit `LD BC,1150` in `src/MATRIXR5.ASM`; a smaller delay is faster. Phase duration is `200 + 3*(RAND & 63)` animation frames, not wall-clock seconds.

Keep original diskettes write-protected and use backup copies when testing software.
