------------------------------------------------------------------------------------------------
--- This module will handle read/write operations to/from the VRAM.
--- It will interface with the FPGA's on-chip memory.
/*
basic memory implementation to utilize dual-port RAM, which allows simultaneous read/write 
operations on two different addresses. This can be extremely useful in a GPU setting where 
one part of the system might be writing data (e.g., the PPU) while another part reads data 
(e.g., the VGA controller).
*/
/*

For your FPGA, the EP2C35F672C6N, here are the details:

    It has 105 M4K blocks.
    Each M4K block has 4,608 bits.
    It can be configured as 4,096 x 1-bit, 2,048 x 2-bit, 1,024 x 4-bit, 512 x 9-bit, and so on.
    It supports true dual-port, simple dual-port, and single-port RAM configurations.

To use the on-chip M4K blocks in your design, you have a few methods:

    Use Quartus II Memory IP: Quartus provides a memory IP that allows you to configure the 
	 memory as you wish. You can set the width, depth, and type of RAM (dual-port, single-port). 
	 This is the most straightforward method.
    
	 
	 Instantiation: You can directly instantiate the M4K blocks in your VHDL or Verilog code. 
	 This method requires a bit more knowledge about the FPGA's architecture but offers more control.



*/

-- i will use a 2 byte wide memory
/*
If you have a memory width of 16 bits (2 bytes) and a depth of, say, 1024 
(which means you can store 1024 16-bit values), 
then the total memory would be 16×1024=1638416×1024=16384 bits or 16 Kbits.
*/
---
---
------------------------------------------------------------------------------------------------




