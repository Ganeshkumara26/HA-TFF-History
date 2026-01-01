# The Pivot: Research Direction

## From Integration Tester to Hardware Architect
My internship objective was hardware/software integration and benchmarking. I accomplished this by May 25th.

However, by benchmarking the software, I identified its physical limits. Software cannot guarantee deterministic latency. Software cannot filter 10Gbps line-rate traffic without massive CPU burn. The offloading strategy is clear.

## The Proposal
Starting in June, I am transitioning into custom digital logic design.
I am going to build a **Hardware-Accelerated Traffic Filter Firewall (HA-TFF)**.

## Goal for the Next Phase (June Onwards)
Apply my foundational Verilog/AXI knowledge to design a physical pipeline on an Artix-7 FPGA that can parse and filter network traffic in deterministic clock cycles (Vol2).
