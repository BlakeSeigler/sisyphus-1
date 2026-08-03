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
        4'b0111: C = A >> B[4:0];             // unsigned shift right
        4'b1000: C = $signed(A) >>> B[4:0];      // signed shift right
        4'b1001: C = A << B[4:0];                 // shift left

        default: C = 32'b0;       // here to be safe
    endcase

    if (C == 32'b0) zero = 1; else zero = 0;

end

endmodule
