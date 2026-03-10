SPI Communication Module (RTL Design & Verification)
Project Overview
This project features a complete SPI (Serial Peripheral Interface) communication system, including both Master and Slave modules. The design was implemented in Verilog HDL, synthesized for the Xilinx Artix-7 (Basys 3) FPGA, and verified through extensive testbench simulations.

Key Features
Full-Duplex Communication: Simultaneous data transmission and reception between Master and Slave.

RTL Design: Modular Verilog implementation with clear separation of control logic and shift registers.

FPGA Optimized: Synthesized using Vivado Design Suite, with successful hardware utilization mapping on the XC7A35T device.

Comprehensive Verification: Includes a self-checking testbench that validates data integrity across multiple 8-bit transactions.

Technical Specifications
Hardware Target: Xilinx Artix-7 (Basys 3)

Tools: Vivado ML, Modelsim/Vivado Simulator

Protocol: SPI (Mode 0: CPOL=0, CPHA=0)

Data Width: 8-bit programmable packets
