# Sisyphus-1 Roadmap

Building a single-cycle RV32I 32-bit CPU + minimal C OS, targeting a Tang Nano 20k.
No pipelining until the single-cycle version fully works.

Effort estimates are in "sessions" (roughly one sitting, 1-3 hrs) — this is a
learning project, not a sprint. Go in order; each milestone assumes the last works.

---

## M0 — Toolchain & Project Setup (~1-2 sessions)
- [ ] Install a Verilog/SystemVerilog simulator: Icarus Verilog or Verilator
- [ ] Install a waveform viewer: GTKWave or Surfer
- [ ] Install the Gowin toolchain for the Tang Nano 20k (for later FPGA bring-up)
- [ ] Write one trivial testbench (e.g. a blinker or a 2-input AND gate) to prove
      sim → waveform round-trip works before touching real RTL
- [ ] Decide on a directory convention for `rtl/` vs `tb/` (testbenches) and stick to it

## M1 — ALU (in progress)
- [ ] Fix `alu_module.sv` port list: `a`, `b`, `c` need to be `[31:0]`, `opcode`
      needs to be `[3:0]` (per your op table in `alu.md`), remove the trailing
      comma in the port list (currently a syntax error), drop the unused `clk`
      (ALU is combinational — no clock needed)
- [ ] Implement each op: ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA
- [ ] Wire up `overflow`, `negative`, `zero` flags correctly for signed ops
- [ ] Write a testbench with directed test vectors per op (include edge cases:
      0, -1, INT_MIN/MAX, shift by 0 and by 31)
- [ ] (stretch) add randomized test vectors checked against a Python/C reference model

## M2 — Register File (~1 session)
- [ ] 32 x 32-bit registers, 2 combinational read ports, 1 synchronous write port
- [ ] `x0` hardwired to zero (writes to it are no-ops)
- [ ] Testbench: write-then-read same cycle, confirm x0 always reads 0

## M3 — Immediate Generator + Instruction Fields (~1 session)
- [ ] Decode opcode, rd, rs1, rs2, funct3, funct7 from a 32-bit instruction word
- [ ] Sign-extend immediates for I-type, S-type, B-type, U-type, J-type formats
- [ ] Testbench: one instruction word per format, check extracted/extended fields

## M4 — Control Unit (~1-2 sessions)
- [ ] Build the opcode/funct3/funct7 → control signal truth table (ALUOp, ALUSrc,
      RegWrite, MemRead, MemWrite, MemtoReg, Branch, Jump)
- [ ] Implement as combinational logic (case statement is fine to start)
- [ ] Testbench: one instruction per RV32I instruction type, check signals match

## M5 — Single-Cycle Datapath Integration (~2-3 sessions)
- [ ] Memory: BRAM initialized via `$readmemh` from a hex file for now (instruction
      memory to start; unify with data memory once loads/stores are wired up)
- [ ] Wire PC → IMem → decode → RegFile/ImmGen → ALU → DMem → writeback mux → RegFile
- [ ] Get R-type instructions working end-to-end in sim first (simplest control path)
- [ ] Add I-type (immediate ALU ops)
- [ ] Add loads/stores (word first, then halfword/byte with sign/zero extend)
- [ ] Add branches (BEQ/BNE/BLT/BGE/BLTU/BGEU) + PC mux
- [ ] Add jumps (JAL/JALR)
- [ ] Add U-type (LUI/AUIPC)

## M6 — Full RV32I Verification (~1-2 sessions)
- [ ] Hand-write a small assembly test program exercising every instruction
- [ ] Assemble it (or hand-encode to hex) and run it against your CPU in sim
- [ ] (stretch) run the official `riscv-tests` RV32UI suite if you can get a
      toolchain to produce compatible memory images

## M7 — FPGA Bring-Up (~2-3 sessions)
- [ ] Get a trivial design (LED blinker) building and flashing via Gowin toolchain
- [ ] Get your CPU synthesizing (fix any tool-specific SystemVerilog issues)
- [ ] Run a simple program from BRAM on real hardware, blink an LED as proof of life
- [ ] Check LUT usage against the 20,736 budget

## M8 — Peripherals & Minimal OS (~ongoing)
- [ ] Bootware: tells the CPU where to start executing
- [ ] UART driver (usb-c) for host communication
- [ ] Shell: basic arithmetic commands, read input / print output
- [ ] Hardware exerciser: stress test to see real throughput limits

## M9 — Pipelining (stretch, after M5-M8 work)
- [ ] Start with a simple 3-stage or 5-stage pipeline (per your own note in
      `ProcessorDesign.md`)
- [ ] Add hazard detection (data hazards, load-use hazard)
- [ ] Add forwarding/bypassing
- [ ] Add branch handling (stall or simple predict-not-taken)

---

## Open Questions (from your notes, unresolved)
- How is pipeline vs. OS scheduler responsibility split? (Pipeline = CPU-level
  instruction overlap; scheduler = OS-level "which process runs next" — these
  are different layers and mostly independent, but worth revisiting once M9 is near.)
- Cache sizing: given the Tang Nano 20k's BRAM (~869KB total), you likely don't
  need a traditional L1/L2/L3 split — BRAM itself can serve as your only cache
  level, or you may skip caching entirely for v1 and go straight to SDRAM.
