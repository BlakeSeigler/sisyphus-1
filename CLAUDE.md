# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Sisyphus-1 is a learning project: designing and building a single-cycle RV32I 32-bit CPU
in SystemVerilog, plus a minimal filesystem-less C-based OS, targeting a Tang Nano 20k
FPGA board but can be changed to a different board if needed. The goal is understanding computer architecture from the gates up, not
shipping a product — expect the pace and structure of a hobbyist learning project rather
than production firmware.

**This is educational — the user wants to write the RTL/HDL and code themselves.**
Use `docs/` (and conversation) to work through design and architecture together, but do
not write or edit SystemVerilog/HDL or other implementation code unless explicitly asked
to help with it. Default to discussion, explanation, and updating design docs; let the
user do the implementing.

No pipelining until the single-cycle datapath fully works end-to-end (pipelining is a
stretch goal — see M9 in `TODO.md`).

## Current state (read this before assuming anything works)

This project is early-stage. No simulator, waveform viewer, or FPGA toolchain has been
set up yet (M0 in `TODO.md` is unchecked), so there are **no build/lint/test commands to
run** — don't invent or assume any (no Makefile, testbenches, or CI exist). The RTL files
in `sisyphus1/rtl/` are stubs/placeholders, not working modules:

- `alu_module.sv` has a known-broken port list (ports declared as scalar `a`, `b`, `c`
  instead of `[31:0]`, `opcode` should be `[3:0]`, has a trailing comma making it a syntax
  error, and an unused `clk` even though the ALU should be purely combinational). See the
  M1 checklist in `TODO.md` for the exact fix list before touching this file.
- `cpu_core.sv` and `sisyphus1_top.sv` are skeletons with `...` placeholders for
  instantiation ports — not yet real module instantiations.
- `sisyphus1_common.sv` currently just holds shared constants (e.g. `WIDTH = 32`).

When asked to work on the RTL, check `TODO.md` first for the current milestone (M0–M9)
and treat it as the authoritative task list/roadmap — work through milestones in order
rather than jumping ahead, since each milestone assumes the previous one is functional.

## Architecture and design references

Design notes live in `docs/` and are the source of truth for architectural decisions;
read the relevant one before making a design choice rather than re-deriving it:

- `docs/General Design.md` — open questions/notes on RAM types, FPGA building blocks
  (CLBs, LUTs, DSPs, BRAM, PLLs), and cache sizing tradeoffs specific to the Tang Nano 20k.
- `docs/busses.md` — notes on tri-state bus behavior and bus-master arbitration.
- `docs/core/ProcessorDesign.md` — overall CPU specs (32-bit, RV32I, single-cycle first)
  and per-component notes (ALU, register file, control unit, L1 cache).
- `docs/core/submodules/alu.md` — the ALU opcode table (4-bit opcode → operation, e.g.
  `0000` = ADD, `0001` = SUB, `1111` = SRA). Treat this as the spec `alu_module.sv` must
  implement; RV32I funct3/funct7 encodings for these ops are largely separate from this
  table so line them up carefully when wiring the control unit.
- `docs/core/osDesign.md` — the OS is intentionally minimal: no filesystem, just a
  bootware, a UART driver (over USB-C) for host communication, a basic arithmetic shell,
  and a hardware exerciser/stress test.
- `docs/core/CarrierHardware.md` — target board specs: Tang Nano 20k, 828KB+41KB BRAM
  (intended as L1 cache), 64MB SDRAM (32-bit width), 64MB QSPI NOR storage, 20,736 LUTs
  budget, HDMI/USB-C connectors. Keep LUT budget in mind when adding RTL complexity.

## Repository layout

- `sisyphus1/rtl/` — SystemVerilog RTL source (no separate `tb/` for testbenches exists
  yet; M0 calls for deciding this convention).
- `docs/` — architecture and design notes, organized as general docs (`docs/`) vs.
  per-core-component notes (`docs/core/`) vs. per-submodule detail (`docs/core/submodules/`).
- `TODO.md` — the authoritative, ordered milestone roadmap (M0–M9) with effort estimates.
- `TODO2.md` — older, informal scratch notes; superseded by `TODO.md`.
