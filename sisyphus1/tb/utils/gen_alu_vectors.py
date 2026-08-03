#!/usr/bin/env python3
# Generates ALU test vectors for the ops that need an independently-derived
# reference (SLT/SLTU/SRL/SRA/SLL) and writes them as one packed hex line per
# test case, for $readmemh to load into the testbench. ADD/SUB/AND/OR/XOR are
# unambiguous enough to self-check directly in the testbench, so they're not
# generated here.
#
# Run it from anywhere with:  python3 sisyphus1/tb/gen_alu_vectors.py
# It writes sisyphus1/tb/alu_vectors.hex next to this script.

import random

MASK32 = 0xFFFFFFFF
OPCODES = [0x5, 0x6, 0x7, 0x8, 0x9]  # SLT, SLTU, SRL, SRA, SLL

def to_signed(x):
    x &= MASK32
    return x - 0x100000000 if x & 0x80000000 else x

def alu_ref(a, b, opcode):
    a &= MASK32
    b &= MASK32
    shamt = b & 0x1F  # only the low 5 bits of B are a valid shift amount

    if opcode == 0x5:  # SLT (signed)
        return 1 if to_signed(a) < to_signed(b) else 0
    if opcode == 0x6:  # SLTU (unsigned)
        return 1 if a < b else 0
    if opcode == 0x7:  # SRL (logical right)
        return a >> shamt
    if opcode == 0x8:  # SRA (arithmetic right)
        return (to_signed(a) >> shamt) & MASK32
    if opcode == 0x9:  # SLL (shift left)
        return (a << shamt) & MASK32
    return 0

# A few known-tricky values worth hitting deliberately, not just by luck.
EDGE_VALUES = [0x00000000, 0x00000001, 0xFFFFFFFF, 0x80000000, 0x7FFFFFFF]
EDGE_SHIFTS = [0, 1, 31]

def edge_cases():
    cases = []
    for opcode in OPCODES:
        for a in EDGE_VALUES:
            for b in EDGE_VALUES:
                cases.append((a, b, opcode))
        if opcode in (0x7, 0x8, 0x9):  # shifts: also hit exact boundary amounts
            for a in EDGE_VALUES:
                for shamt in EDGE_SHIFTS:
                    cases.append((a, shamt, opcode))
    return cases

def random_cases(per_opcode=2000, seed=12345):
    rng = random.Random(seed)
    cases = []
    for opcode in OPCODES:
        for _ in range(per_opcode):
            a = rng.getrandbits(32)
            b = rng.getrandbits(32)
            cases.append((a, b, opcode))
    return cases

def main():
    all_cases = edge_cases() + random_cases()
    out_path = __file__.rsplit("/", 1)[0] + "/alu_vectors.hex"
    with open(out_path, "w") as f:
        for a, b, opcode in all_cases:
            expected = alu_ref(a, b, opcode)
            # 8 hex digits A, 8 hex digits B, 1 hex digit opcode, 8 hex digits expected
            # = 25 hex digits = 100 bits total, matches reg [99:0] on the Verilog side.
            f.write(f"{a:08x}{b:08x}{opcode:01x}{expected:08x}\n")
    print(f"Wrote {len(all_cases)} test vectors to {out_path}")

if __name__ == "__main__":
    main()
