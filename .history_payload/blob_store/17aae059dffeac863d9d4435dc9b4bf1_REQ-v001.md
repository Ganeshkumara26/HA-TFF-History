# Requirement V001: Telemetry Metadata Extraction

## The Problem
Software-based network packet parsing (via CPU kernels) is introducing unacceptably high and variable latency for incoming telemetry streams.

## The Goal
Design a hardware (FPGA) module capable of extracting identifying network metadata (the "5-tuple": Source IP, Destination IP, Source Port, Destination Port, Protocol) directly from a 10 Gigabit Ethernet (10GbE) line.

## Constraints
1. Must interface with standard AXI4-Stream protocols.
2. Must sustain 10GbE line rates (64-bit data bus @ 156.25 MHz).
3. Minimum area overhead (we are targeting an Artix-7 fabric).
