RAM Types:
BRAM
DRAM
SRAM
SDRAM


How does the ram setup on the fpga work? 
> what are ddr2 / ddr3?

How much ram and storage do I need for my OS?

How big do the L1, L2, and L3 caches need to be? Do I need all of them? How big do I make these?

FPGA Types:
- SoM boards -- just the brain 
- Dev Boards -- brain with lots of peripherals
- Core Boards -- brain with very limited peripherals
*Carrier boards - the mounting board you put SoM boards on. usually make these custom and mount your SoM on it.

*FPGAs are made of
CLBs
LUTs
DSPs
BRAM
PLLs

I'm gonna need to write some basic stuff up and then spec out the board i need for my fpga. I think i'm gonna get one with some ram and storage on the board external so I can use that. 

I will need to make sure the board i get has enough LUTs to handle the cpu I want to make, though I'm unsure what exactly that number or order of magniitude looks like.

what exactly is a register and how do they work