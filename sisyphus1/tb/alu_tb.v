module alu_tb ();
    reg [31:0] A0;
    reg [31:0] B0;
    reg [3:0] opcode0;
    reg [31:0] expected;
    wire [31:0] C0;
    wire zero0;
    reg [99:0] test_vectors [0:10169];

    integer i;
    integer seed;
    integer errors;
    integer total;

    // Make the ALU module
    alu alu_instance (
        .A(A0),
        .B(B0),
        .opcode(opcode0),
        .C(C0),
        .zero(zero0)
    );

    task test_case;
        begin
            #1;
            total = total + 1;
            if (C0 !== expected) begin
                errors = errors + 1;
                $display("FAIL: A=%h B=%h op=%b got=%h expected=%h", A0, B0, opcode0, C0, expected);
            end
        end
    endtask

    // Run test casess
    initial begin
        errors = 0;
        total = 0;
        seed = 12345;   // fixed starting point -> same run every time, for reproducible failures

        // --------------------------------------
        // Start calling test cases down here
        // --------------------------------------

        // Start with Add
        // 1 -- random
        opcode0 = 4'b0000;
        for (i = 0; i < 10000; i = i+1) begin
            A0 = $random(seed);   // passing the seed VARIABLE each time lets it evolve
            B0 = $random(seed);
            expected = A0 + B0;
            test_case();
        end
        // 2 -- overflow
        A0 = 32'hFFFFFFFF;
        B0 = 32'h00000001;
        expected = 32'b0;
        test_case();


        // Do subtract
        // 1 -- random
        opcode0 = 4'b0001;
        for (i = 0; i < 10000; i = i+1) begin
            A0 = $random(seed);
            B0 = $random(seed);
            expected = A0 - B0;
            test_case();
        end
        // 2 -- overflow
        A0 = 32'h00000000;
        B0 = 32'h00000001;
        expected = 32'hFFFFFFFF;
        test_case();


        // Do AND
        opcode0 = 4'b0010;
        for (i = 0; i < 10000; i = i + 1) begin
            A0 = $random(seed);
            B0 = $random(seed);
            expected = A0 & B0;      // fine since its trustworthy but not good practice -- just helps syntax reps
            test_case();
        end

        // Do OR
        opcode0 = 4'b0011;
        for (i = 0; i < 10000; i = i + 1) begin
            A0 = $random(seed);
            B0 = $random(seed);
            expected = A0 | B0;      // fine since its trustworthy but not good practice -- just helps syntax reps
            test_case();
        end

        // Do XOR
        opcode0 = 4'b0100;
        for (i = 0; i < 10000; i = i + 1) begin
            A0 = $random(seed);
            B0 = $random(seed);
            expected = A0 ^ B0;     // fine since its trustworthy but not good practice -- just helps syntax reps
            test_case();
        end

        // Do SLT, Do SLTU, Do SRL, Do SRA, Do SLL  -- 
        // These I check with python again for some test wreps on different tools
        $readmemh("./sisyphus1/tb/utils/alu_vectors.hex", test_vectors);
        for (i = 0; i < 10170; i = i + 1) begin
            A0       = test_vectors[i][99:68];
            B0       = test_vectors[i][67:36];
            opcode0  = test_vectors[i][35:32];
            expected = test_vectors[i][31:0];
            test_case();
        end

        $display("%0d / %0d passed", total - errors, total);
        $finish;
    end

endmodule
