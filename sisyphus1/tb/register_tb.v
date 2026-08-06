module register_tb ();

    reg [4:0] rs1_addr;
    reg [4:0] rs2_addr;
    reg rw1;
    reg [4:0] rw_addr;
    reg [31:0] rw_data;
    reg clk;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    integer errors;
    integer total;
    integer i;
    integer seed;
    reg [4:0] rand_addr;
    reg [31:0] rand_data_old;
    reg [31:0] rand_data_new;

    register register_instance (
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rw1(rw1),
        .rw_addr(rw_addr),
        .rw_data(rw_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .clk(clk)
    );

    // Free-running clock: flips every 5 time units -> 10-unit period
    always #5 clk = ~clk;

    // Commits a write and waits for it to actually land before returning
    task write_reg;
        input [4:0] addr;
        input [31:0] data;
        begin
            rw_addr = addr;
            rw_data = data;
            rw1 = 1;
            @(posedge clk);
            #1;
            rw1 = 0;
            #1;
        end
    endtask

    initial begin
        $dumpfile("register_tb.vcd");
        $dumpvars(0, register_tb);

        clk = 0;
        rw1 = 0;
        errors = 0;
        total = 0;
        seed = 54321;

        // -------------------------------------------------------
        // test out x0
        // -------------------------------------------------------
        rs1_addr = 5'b0;
        #1;
        if (rs1_data == 32'b0) begin // first read is good
            rw1 = 1;
            rw_addr = 5'b0;
            rw_data = 32'b1;
            @(posedge clk); // wait for the write to actually commit
            #1;             // let the combinational read settle after the edge
            if (rs1_data == 32'b0) begin // write was correctly ignored
                $display("Passed the x0 test!");
            end
            else begin
                $display("Failed the x0 test on write-read");
            end
        end
        else begin
            $display("Failed x0 test: x0 not 0");
        end
        rw1 = 0;

        // -------------------------------------------------------
        // test write-then-read same cycle, ordinary registers
        // -------------------------------------------------------
        for (i = 0; i < 50; i = i + 1) begin
            total = total + 1;

            rand_addr = $random(seed);
            if (rand_addr == 5'd0) rand_addr = 5'd1; // x0 already covered above
            rand_data_old = $random(seed);
            rand_data_new = $random(seed);

            // get a known baseline value into the register first
            write_reg(rand_addr, rand_data_old);

            // read it -- should show the old value before any new write commits
            rs1_addr = rand_addr;
            #1;
            if (rs1_data !== rand_data_old) begin
                errors = errors + 1;
                $display("FAIL (pre-write): addr=%0d expected=%h got=%h", rand_addr, rand_data_old, rs1_data);
            end

            // now write a new value to the same address, same address still being read
            rw_addr = rand_addr;
            rw_data = rand_data_new;
            rw1 = 1;
            @(posedge clk);
            #1;
            rw1 = 0;

            // should show the new value immediately after the edge commits
            if (rs1_data !== rand_data_new) begin
                errors = errors + 1;
                $display("FAIL (post-write): addr=%0d expected=%h got=%h", rand_addr, rand_data_new, rs1_data);
            end
        end

        $display("write-then-read: %0d / %0d passed", total - errors, total);
        $finish;
    end

endmodule
