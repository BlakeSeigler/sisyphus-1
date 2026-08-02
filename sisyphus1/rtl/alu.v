module alu (
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [3:0] opcode,
    output reg [31:0] C,
    output reg zero         // might not get used but want to keep for completeness
);

always @(A, B, opcode) begin

    case (opcode)
        4'b0000: C = A + B;
        4'b0001: C = A - B;
        4'b0010: C = A & B;
        4'b0011: C = A | B;
        4'b0100: C = A ^ B;
        4'b0101: C = ($signed(A) < $signed(B)) ? 1 : 0;
        4'b0110: C = ($unsigned(A) < $unsigned(B)) ? 1 : 0;
        4'b0111: C = A >> B;             // unsigned shift right
        4'b1000: C = $signed(A) >>> B;      // signed shift right
        4'b1001: C = A << B;                 // shift left

        default: C = 32'b0;       // here to be safe
    endcase

    if (C == 32'b0) zero = 1; else zero = 0;

end

endmodule

/*
 * Notes on shifting (why only 5 bits of the shift amount matter):
 *
 * RV32I defines the shift amount for SLL/SRL/SRA as only the lower 5 bits
 * of the second operand (the immediate shamt field, or the rs2 register
 * value) - not the full 32 bits. A 32-bit value only has 32 distinct shift
 * positions (0-31) before every original bit has been shifted out entirely,
 * so there's no additional behavior to define past 5 bits of amount:
 *
 *   - Immediate shifts (SLLI/SRLI/SRAI) only have a 5-bit shamt field in
 *     the instruction encoding to begin with - there's no room for more.
 *   - Register shifts (SLL/SRL/SRA) read rs2 at runtime, which could hold
 *     any 32-bit value (e.g. leftover bits above bit 4 from an unrelated
 *     prior computation). The spec masks to rs2[4:0] so the result stays
 *     well-defined and matches immediate-shift behavior, reusing the same
 *     5-bit-controlled shifter for both forms instead of special-casing
 *     "large" runtime shift amounts.
 *
 * => Shift amount inputs to this ALU should be masked to B[4:0], not the
 *    full 32-bit B. (Not yet done in this file.)
 *
 * always @(*):
 *
 * Shorthand for an automatically-inferred sensitivity list. Instead of
 * manually naming every signal a block depends on, the tool scans the
 * block's body and treats every signal read inside it as a trigger,
 * re-evaluating whenever any of them change. Safer than an explicit list
 * like @(A, B, opcode) because it can't go stale - if a new input is added
 * later and someone forgets to add it to an explicit list, simulation
 * stops updating on that signal's changes even though real (synthesized)
 * hardware would still react to it immediately.
 */

