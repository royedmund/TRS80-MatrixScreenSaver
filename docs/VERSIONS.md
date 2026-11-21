# Matrix Screen Saver version history

- **MATRIX3** — The first 64×16 falling-code program with uppercase and solid character heads, accompanied by a BASIC listing.
- **MATRIXFX** — Adds lowercase, extended special symbols and semigraphics.
- **MATRIXF2** — Removes the full-block character (191) and period (46), colon (58), and semicolon (59). BASIC listing available.
- **MATRIXR3** — Different speeds per column, overlapping streams, changing symbols and variable gaps. BASIC listing available.
- **MATRIXR4** — Random normal and invisible-rain phases; clears the whole screen at mode change.
- **MATRIXR5** — Earlier progressive-blank release. During the invisible phase, streams continue falling but write ASCII 32 at their normal moving positions, progressively replacing existing code, without clearing the entire screen at mode change.

- **MATRIXR6** — **Current release.** Falling spaces progressively erase existing code for approximately **one second** (38 animation frames), then visible rain resumes. The normal phase remains random 5–10 seconds. No full-screen clear occurs at phase changes.

All programs are for a 48 KB TRS-80 Model III. Their special symbols depend on the installed character ROM. Later versions avoid glyph codes 191, 46, 58 and 59.
