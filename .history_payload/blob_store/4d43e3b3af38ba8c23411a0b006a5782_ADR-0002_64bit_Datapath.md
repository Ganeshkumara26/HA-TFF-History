# Architecture Decision Record: ADR-0002

## Title
Expansion of Parser Datapath to 64-bit AXI4-Stream

## Date
2026-01-08

## Status
Accepted

## Context & Problem
The initial `ha_tff_parser_v001` processed incoming packets at 1 byte per clock cycle. While this simplified the FSM state logic, simulation proved that at a typical FPGA clock frequency of 156.25 MHz, an 8-bit datapath yields a maximum throughput of 1.25 Gbps. To achieve the 10Gbps line rate required for modern drone infrastructure, the datapath must be widened. 

## Engineering Question
What is the optimal datapath width for the HA-TFF to support a 10Gbps line rate while minimizing logical complexity?

## Options

### Option A: 32-bit Datapath (4 bytes/cycle)
- **Advantages**: Easier to align standard IPv4 headers, which are typically 32-bit aligned.
- **Disadvantages**: At 156.25 MHz, 32 bits yields exactly 5 Gbps. To hit 10 Gbps, the clock frequency must be 312.5 MHz, which is difficult to close timing on in standard FPGA fabrics (e.g., Xilinx 7-series or UltraScale without deep pipelining).

### Option B: 64-bit Datapath (8 bytes/cycle)
- **Advantages**: At 156.25 MHz, 64 bits yields exactly 10 Gbps. This matches the standard Xilinx 10G Ethernet MAC interface (XGMII/AXI4-Stream).
- **Disadvantages**: Increased complexity in parsing. A 64-bit word can contain partial headers. For instance, the Ethernet header is 14 bytes (not a multiple of 8). This means the IPv4 header will start at byte offset 6 inside the second 64-bit word, requiring byte-shifting and concatenation across cycles.

### Option C: 256-bit Datapath (32 bytes/cycle)
- **Advantages**: Can parse almost the entire header (Ethernet + IP + UDP) in a single clock cycle, greatly simplifying the FSM depth. Used for 40G/100G interfaces.
- **Disadvantages**: Overkill for 10G. Consumes massive routing resources and creates wide multiplexers, leading to potential routing congestion.

## Decision
Choose **Option B**: Implement a 64-bit (8 bytes/cycle) AXI4-Stream datapath.

## Reason
A 64-bit datapath at 156.25 MHz is the industry standard for 10GbE implementations on FPGA. It provides the exact bandwidth needed without over-provisioning logic resources. The complexity of unaligned headers (due to the 14-byte Ethernet header) will be managed by careful register shifting.

## Future Implications
The next RTL module (`ha_tff_parser_v002`) will require a pipeline that buffers the previous 64-bit word to concatenate unaligned IP and UDP fields. The testbench must be updated to inject 8 bytes per clock cycle, simulating a 10G Ethernet MAC output.
