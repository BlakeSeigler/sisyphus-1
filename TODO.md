# Sisyphus-1 Roadmap

Building a single-cycle RV32I 32-bit CPU + minimal C OS, targeting a Tang Nano 20k.
No pipelining until the single-cycle version fully works.

---

## M0 — Toolchain & Project Setup 
- [ ] Install a Verilog/SystemVerilog simulator: Icarus Verilog or Verilator
- [ ] Install a waveform viewer: GTKWave or Surfer
- [ ] Install the Gowin toolchain for the Tang Nano 20k (for later FPGA bring-up)
- [ ] Write one trivial testbench (e.g. a blinker or a 2-input AND gate) to prove
      sim → waveform round-trip works before touching real RTL
- [ ] Decide on a directory convention for `rtl/` vs `tb/` (testbenches) and stick to it

## M1 — ALU
- [ ] Fix `alu_module.sv` port list: `a`, `b`, `c` need to be `[31:0]`, `opcode`
      needs to be `[3:0]` (per your op table in `alu.md`), remove the trailing
      comma in the port list (currently a syntax error), drop the unused `clk`
      (ALU is combinational — no clock needed)
- [ ] Implement each op: ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA
- [ ] Wire up `overflow`, `negative`, `zero` flags correctly for signed ops
- [ ] Write a testbench with directed test vectors per op (include edge cases:
      0, -1, INT_MIN/MAX, shift by 0 and by 31)
- [ ] (stretch) add randomized test vectors checked against a Python/C reference model

## M2 — Register File 
- [ ] 32 x 32-bit registers, 2 combinational read ports, 1 synchronous write port
- [ ] `x0` hardwired to zero (writes to it are no-ops)
- [ ] Testbench: write-then-read same cycle, confirm x0 always reads 0

## M3 — Immediate Generator + Instruction Fields 
- [ ] Decode opcode, rd, rs1, rs2, funct3, funct7 from a 32-bit instruction word
- [ ] Sign-extend immediates for I-type, S-type, B-type, U-type, J-type formats
- [ ] Testbench: one instruction word per format, check extracted/extended fields

## M4 — Control Unit 
- [ ] Build the opcode/funct3/funct7 → control signal truth table (ALUOp, ALUSrc,
      RegWrite, MemRead, MemWrite, MemtoReg, Branch, Jump)
- [ ] Implement as combinational logic (case statement is fine to start)
- [ ] Testbench: one instruction per RV32I instruction type, check signals match

## M5 — Single-Cycle Datapath Integration 
- [ ] Memory: BRAM initialized via `$readmemh` from a hex file for now (instruction
      memory to start; unify with data memory once loads/stores are wired up)
- [ ] Wire PC → IMem → decode → RegFile/ImmGen → ALU → DMem → writeback mux → RegFile
- [ ] Get R-type instructions working end-to-end in sim first (simplest control path)
- [ ] Add I-type (immediate ALU ops)
- [ ] Add loads/stores (word first, then halfword/byte with sign/zero extend)
- [ ] Add branches (BEQ/BNE/BLT/BGE/BLTU/BGEU) + PC mux
- [ ] Add jumps (JAL/JALR)
- [ ] Add U-type (LUI/AUIPC)

## M6 — Full RV32I Verification
- [ ] Hand-write a small assembly test program exercising every instruction
- [ ] Assemble it (or hand-encode to hex) and run it against your CPU in sim
- [ ] (stretch) run the official `riscv-tests` RV32UI suite if you can get a
      toolchain to produce compatible memory images

## M7 — FPGA Bring-Up 
- [ ] Get a trivial design (LED blinker) building and flashing via Gowin toolchain
- [ ] Get your CPU synthesizing (fix any tool-specific SystemVerilog issues)
- [ ] Run a simple program from BRAM on real hardware, blink an LED as proof of life
- [ ] Check LUT usage against the 20,736 budget

## M8 — Peripherals & Minimal OS 

### Boot flow
- [ ] Decide + design the QSPI NOR boot flow: how the OS image gets copied from
      QSPI NOR into BRAM/SDRAM at power-on before the CPU starts executing
- [ ] (optional, dev convenience) UART-based loader as a faster iterate-without-
      reflashing path during development, separate from the "real" QSPI boot flow

### Memory-mapped I/O
- [ ] Reserve an address range for peripheral registers and add address-decode
      logic so loads/stores in that range route to peripherals instead of DMem

### UART driver
- [ ] RTL: TX/RX module (baud-rate generator, shift registers) wired onto the
      memory-mapped bus
- [ ] Software: small C routines to write/read the UART's memory-mapped
      registers (e.g. putc/getc) for host communication over USB-C

### Shell
- [ ] Basic arithmetic commands, read input / print output over UART

### Hardware exerciser
- [ ] Stress test to see real throughput limits

### Deferred / not required for v1
- [ ] CSRs + trap handling (ECALL/EBREAK, interrupts) — only needed if the OS
      has to gracefully handle faults or asynchronous events; the current OS is
      a simple polling loop with no protection domains, so this can stay out of
      scope unless a concrete need for it shows up

---

## Future Goals 

### Pipelining 
- [ ] Start with a simple 3-stage or 5-stage pipeline (per your own note in
      `ProcessorDesign.md`)
- [ ] Add hazard detection (data hazards, load-use hazard)
- [ ] Add forwarding/bypassing
- [ ] Add branch handling (stall or simple predict-not-taken)

### HDMI / Video Output
- [ ] Pixel clock generation via PLL
- [ ] Video timing generator (hsync/vsync, active-video window)
- [ ] TMDS encoder/serializer to actually drive the board's HDMI port
- [ ] (further out) framebuffer if you want more than fixed/generated patterns

