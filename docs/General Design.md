## General

How much ram and storage do I need for my OS?

what exactly is a register and how do they work

How is a pipeline and a scheduler different? I'm guessing pipeline is for the cpi to run on and the schedular is the os level job but I don't see exactly how they interact yet so I'm still a little confused.


## FPGAs

How does the ram setup on the fpga work?
> answer: 

How big do the L1, L2, and L3 caches need to be? Do I need all of them? How big do I make these?

FPGA Types:
- SoM boards -- just the brain with some peripherals
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




## RAM Types:
BRAM - Block RAM, this is built into an FPGA directly and is extremely fast

DRAM - Dynamic RAM, this is the most common type of RAM found in computers, it stores values in a capacitor and needs to be constantly refreshed. Their are further subsets of this (see SDRAM below)

SRAM - Static RAM, uses flip flops to store data and constantly flags the circuit. Due to this it is much faster and more expensive than DRAM so this type is generally used for L1, L2, and L3 caches.

SDRAM - Synchronous DRAM, is DRAM that coordinates with the clock signal in the computer. This makes it predictable and efficient (DDR2, DDR3, DDR4, DDR5 and SDR (single data rate) are types of this ram). Virtually all RAM in computers is this type, note this is a subset of DRAM. When people say SDRAM as opposed to DDR3 they typically mean SDR SDRAM.




## Storage

Configurable Storage: this storage is used by the device to load confguration data. My Tang Nano 20k has QSPI Nor. 

External Storage: Extra storage used for other purposes.

On this device I will likely just load my OS into the QSPI NOR storage since it should be small enough. 64MB should be plenty considering my OS likely won't break 100 KBs.

## Fun Facts

I did not realize this but FPGAs are literally just breadboards for ASICs. It allows you to use the scalability and ease of testing of software do assemble VLSI level circuits. Then you can either leave it on the FPGA or if you need to manufacture at scale you just port to an ASIC and use the incredibly well worn silicon fabrication ecosystem to pump out the chips you need.

