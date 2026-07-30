`include "and.v"

module and_thing_tb ();
    reg a, b;
    wire c;

    and_thing dut(
        .a(a),
        .b(b),
        .c(c)
    );

initial begin
    $dumpfile("and_tb.vcd");
    $dumpvars(0, and_thing_tb);

        // stimulus: drive inputs, wait, check outputs
        a = 0; b = 0; #10;
        $display("a=%b b=%b c=%b", a, b, c);

        a = 0; b = 1; #10;
        $display("a=%b b=%b c=%b", a, b, c);

        a = 1; b = 0; #10;
        $display("a=%b b=%b c=%b", a, b, c);

        a = 1; b = 1; #10;
        $display("a=%b b=%b c=%b", a, b, c);

    $finish;

end;

endmodule;