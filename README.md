
# Simple PPU Project

## Project Overview

The Simple PPU project is a VHDL-based FPGA implementation that aims to utilize parallel processing capabilities by employing 2 ALUs in parallel to make a simple PPU. Screenshots_Simulation are included for demonstration of some of the results.

## Performance Improvements

By leveraging parallel processing, the project has achieved significant performance improvements:

- With a single ALU, the operation took **112690 ns** to both load the RAM and then start reading the arrays to add them.
- With the addition of two elements processed at a time in parallel, the operation time was reduced to **76830 ns**. This translates to a **31.81% improvement**.

## Modules

1. **gpu_pkg.vhd**: Contains package definitions for the project, mainly the data type `array_t`.
2. **gpu_top.vhd**: The top-level module connecting the different components of the project.
3. **memory_controller.vhd**: Manages read/write operations to/from the VRAM, interfacing with the FPGA's on-chip memory.
4. **ppu.vhd**: Contains the basic ALU design, accepting control signals to specify operations.
5. **ppu_controller.vhd**: Orchestrates operations between the memory controller and the PPU.

## Testbenches

The project includes several testbenches for simulation and verification:

1. **tb_gpu_top.vhd**: Testbench for the `gpu_top` module.
2. **tb_memory_controller.vhd**: Testbench for the `memory_controller` module.
3. **tb_ppu.vhd**: Testbench for the `ppu` module.
4. **tb_ppu_controller.vhd**: Testbench for the `ppu_controller` module.

Simulation results and waveforms from these testbenches can be found in the provided screenshots.

## Features

- **PPU**:
  - Custom shift functions.
  - Basic ALU structure.
- **Memory Controller**:
  - Utilizes dual-port RAM for simultaneous read/write operations on two different addresses.
  - Memory can hold up to 512 elements of 2 Byte size per each memory section.
  - Memory is divided into 3 main sections, A,B and C. Where C is the result of the operation done on A and B.
- **PPU Controller**:
  - Supports writing to both RAMs simultaneously.

## FPGA Information

- **VHDL Standard**: VHDL 1993
- **Target FPGA**: Cyclone II DE 2: EP2C35F672C6N
  - Contains 105 M4K blocks.
  - M4K block configurations vary.
  - Supports different RAM configurations including true dual-port, simple dual-port, and single-port.

## Potential Improvements (TODO)

- **PPU**:
  - Implement comparison operations such as EQ, NEQ, GT, LT, GTE, LTE.
  - GPU-specific operations like clamping, interpolation, dot product, and cross product.
  - Improve the way that arrays are stored.
	
---
