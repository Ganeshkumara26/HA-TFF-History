# Requirement V002: Sustained 10GbE Data Rate Compatibility

## The Problem
Iteration 001 (the 8-bit parser) is mathematically incapable of processing a 10 Gbps data stream on an Artix-7 FPGA. To process 10 gigabits per second using an 8-bit (1-byte) data bus, the clock frequency must be:
`10,000,000,000 bits/sec / 8 bits/cycle = 1.25 GHz`.
The maximum Fmax for Artix-7 fabric is generally around 200-300 MHz for complex logic.

## The Goal
The parser must be re-architected to interface with the standard Xilinx 10 Gigabit Ethernet Subsystem (xgmac), which outputs data on a 64-bit wide AXI4-Stream bus at 156.25 MHz.

## Constraints
1. The parser must process an entire 64-bit word (8 bytes) in a single clock cycle.
2. Timing closure must be met at 156.25 MHz.
