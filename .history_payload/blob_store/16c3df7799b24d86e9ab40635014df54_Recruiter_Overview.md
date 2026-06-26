# Recruiter Overview: HA-TFF 

**Role:** Hardware Systems Architect (Intern to Independent Researcher)
**Timeline:** May 2026 - October 2026

## Executive Summary
Transitioned from a software integration role on a Node.js Drone Fleet Management system (MeghDut) to independently designing a custom **Hardware-Accelerated Traffic Filter Firewall (HA-TFF)** on a Xilinx Artix-7 FPGA.

## Technical Achievements
- **Bottleneck Analysis:** Benchmarked Node.js GC pauses during high-frequency MQTT telemetry ingestion, proving the need for hardware offloading.
- **Digital Design (Verilog):** Designed a 64-bit word-aligned AXI-Stream parser achieving deterministic latency.
- **Algorithm in Hardware:** Implemented a 4-way BRAM-based Cuckoo Hashing table using XOR folding for exact-match IP/Port filtering.
- **Neuromorphic Extension:** Designed a DSP-free Spiking Neural Network (Leaky Integrate-and-Fire) to flag behavioral anomalies natively on the datapath.
- **Timing Closure:** Successfully pipelined the architecture to meet strict 156.25 MHz timing constraints, supporting sustained 10GbE line rates.

## Technology Stack
- **Hardware:** Xilinx Artix-7, Vivado Design Suite.
- **Languages:** Verilog, PowerShell, Node.js (Benchmarking).
- **Protocols:** AXI-Stream, Ethernet, IPv4, UDP, MQTT, MAVLink.
