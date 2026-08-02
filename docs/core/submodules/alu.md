## My ALU

* Ripple Over Adder (could have done a Carry Lookahead adder)

Operations:
0000 - Add
0001 - Subtract
0010 - AND
0011 - OR
0100 - XOR
0101 - SLT           // Set less than -- compares -2^N to 2^N
0110 - SLTU          // Set Less than unsigned -- compares 0 to 2^N+1 
0111 - SRL           // Shift Right      
1000 - SRA           // Shift Right Arithmetic
1001 - SLL           // Shift Left

This is the RISC-V32 ISA commands

*RISC-V doesn't need overflow or zero or anything like that. Its made simple and doesn't expect a flag register because of pipelining difficulties although I don't really understand the details and nuances of that decision

Notes:
- what is a barrel shifter? 