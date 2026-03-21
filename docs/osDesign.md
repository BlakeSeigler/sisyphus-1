This OS will not have a filesystem and/or anything else you can possibly think of that makes life enjoyable. I want to run some basic arithmatic on this thing and then have a stress test to run it as fast as possible.

## OS Things

Bootware: 
- This tells the cpu where to start

UART Driver:
- This allows usb-c communication so I can read data

Shell:
- Implement this and some basic arithmetic commands
- Should be able to write arithmatic commands and read outputs

Hardware Exerciser:
- Stress tester for the hardware. I want to get a good sense for what too much math on these things looks like


Testing Setup:
- I can write my os and use RV32I emulators to verify that things are working correctly -- not sure how this translates or abstracts my cpu quite yet.