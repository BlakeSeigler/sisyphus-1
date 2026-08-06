module register(

    // Inputs
    input wire [4:0] rs1_addr,
    input wire [4:0] rs2_addr,
    input wire rw1,
    input wire [4:0] rw_addr,
    input wire [31:0] rw_data,

    // Outputs
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data,

    // Clock
    input wire clk
);

    // Storage
    reg [31:0] regs [31:0];

    // Reads: combinational, always live -- x0 forced to zero regardless of storage
    always @(*) begin
        rs1_data = (rs1_addr == 5'd0) ? 32'b0 : regs[rs1_addr];
        rs2_data = (rs2_addr == 5'd0) ? 32'b0 : regs[rs2_addr];
    end

    // Write: synchronous, commits only on the clock edge -- x0 is never written
    always @(posedge clk) begin
        if (rw1 && rw_addr != 5'd0) begin
            regs[rw_addr] <= rw_data;
        end
    end

endmodule
