# ADR-011: Data Delay Line (Pipeline Alignment)

**Status:** Accepted
**Date:** Week 11 (v011)

## Context
In `v010`, we noticed severe Pipeline Alignment Debt. The Firewall Datapath (Exact Match + SNN) takes 4 clock cycles to decide whether to drop or forward a packet. However, during those 4 cycles, the Ethernet payload (`s_axis_tdata`) has already been flowing out of the FPGA because there is no buffer holding it back. 

We are making a decision on a packet that has already left the building.

## Options Considered

### Option A: AXI-Stream FIFO
Instantiate a standard Xilinx AXI-Stream FIFO IP block.
- **Pros:** Highly robust, handles `tready`/`tvalid` backpressure seamlessly.
- **Cons:** (PHYSICS FIRST). FIFOs consume BRAMs. We need BRAMs for the Cuckoo Hash tables. Since we know our decision latency is exactly deterministic (fixed cycles), a full asynchronous FIFO is massive overkill.

### Option B: Shift Register (Delay Line)
Build a simple shift register (`axi_stream_delay_line.v`) that delays `tdata`, `tkeep`, and `tlast` by exactly the depth of the firewall pipeline.
- **Pros:** Zero BRAM utilization. Maps perfectly to SRL16/SRL32 primitives (Shift Register LUTs) on the Artix-7, which are highly area-efficient.
- **Cons:** Cannot handle complex `tready` backpressure if downstream modules stall.

## Decision
**Option B (Shift Register Delay Line)** is selected.

## Engineering Justification
Because the HA-TFF operates at a sustained 10GbE line rate without stalling, we can guarantee deterministic latency. Thus, we can safely use SRL-based delay lines instead of BRAM-heavy FIFOs. This saves critical BRAM resources for the anomaly detection logic.

## Dependencies
- **Derived From:** N/A
- **Implements:** Pipeline Alignment
- **Creates:** `RTL-v011/axi_stream_delay_line.v`
- **Verified By:** `SIM-011`
