# Installation

For a 48 KB TRS-80 Model III running LDOS 5.1, transfer `bin/MATRIXR6.CMD` into a TRS-80 disk or emulator disk image as `MATRIXR6/CMD`. At the `LDOS READY` prompt enter:

```text
MATRIXR6
```

Release the Enter key and press any key to exit. The program draws directly into 64×16 video RAM starting at `3C00h`, polls the keyboard at `38FFh`, and returns to DOS via `402Dh`.

MATRIXR6 alternates random approximately 5–10-second visible-rain phases with roughly 1-second phases of falling blank (space) characters that progressively erase the previous code. It does **not** clear the screen when changing modes; the screen clears only at startup and exit.

For speed changes, edit `LD BC,1150` in `src/MATRIXR6.ASM`; a smaller delay is faster. Normal phase duration is `200 + 3*(RAND & 63)` animation frames; blank phase is fixed at **38 frames** (approximately one second), not timed against a hardware clock.

Keep original diskettes write-protected and use backup copies when testing software.

## BASIC version

The [`basic/MATRIXR6.BAS`](../basic/MATRIXR6.BAS) file is a **plain-text numbered listing**, not a tokenised BASIC disk file. From the LDOS prompt start BASIC, enter the listing manually (or import it with a suitable emulator/disk utility), then type `RUN`. Once it is in BASIC memory, `SAVE "MATRIXR6/BAS"` stores a native BASIC program on the selected disk.

The BASIC version uses the Model III's software clock registers at addresses `4216h` / `4217h` (decimal `16918` / `16919`) for approximate 30-tick-per-second timing. The normal phase lasts a random 150–300 ticks (roughly 5–10 seconds); the falling-space phase lasts 30 ticks (about one second). Each column retains its state across the mode change, and **no screen clear occurs during the switch**. A full clear happens only on program start and exit.

BASIC is substantially slower than the compiled Z80 version; a one-second blank phase may only draw a few frames. For best visual performance, use `MATRIXR6/CMD`. Make sure the Model III clock is running. The listing has been statically checked but not yet tested on a physical machine.
