#!/usr/bin/env python3
"""Rebuild all TRS-80 Matrix screensaver executables from their Z80 sources."""
from pathlib import Path
import sys
from z80asm_local import assemble, cmd

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "build"
OUT.mkdir(exist_ok=True)
failure = False
for name in ("MATRIX3", "MATRIXFX", "MATRIXF2", "MATRIXR3", "MATRIXR4", "MATRIXR5", "MATRIXR6"):
    source = (ROOT / "src" / (name + ".ASM")).read_text(encoding="utf-8")
    machine, symbols = assemble(source)
    output = cmd(machine)
    (OUT / (name + ".CMD")).write_bytes(output)
    expected = (ROOT / "bin" / (name + ".CMD")).read_bytes()
    ok = output == expected
    failure |= not ok
    print(name, "MATCH" if ok else "MISMATCH", len(output), "bytes")
if failure:
    sys.exit("At least one generated executable differs from the checked-in release")
print("All seven releases rebuilt successfully.")
