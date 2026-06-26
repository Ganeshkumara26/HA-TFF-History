# Engineering Memory - Iteration 004 (Week 4)

## Research Direction & Goals
**Current Goal**: Construct the physical memory banks to hold the Cuckoo Hash table entries.

## Knowledge Boundaries
**Things I understand:**
- I cannot use LUTRAM for this. I must use BRAM. (See `ADR-004`).
- BRAM reads are synchronous, meaning I lose 1 clock cycle waiting for the data to emerge.

**Things I believe:**
- I believe writing a generic parameterized array `reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]` is enough for Vivado to infer BRAMs automatically.

**Things I do not understand:**
- How do I actually insert rules into this BRAM? Usually, there is a MicroBlaze CPU updating a Dual-Port RAM via AXI-Lite. I don't know how to write an AXI-Lite wrapper yet. 
- I opened `Q002` regarding this. For now, I will just use `$readmemh` in simulation.

## Architecture & Math
See `ARCH-v004`. The math confirms we will use exactly 12 `RAMB36E1` primitives. We have plenty of silicon space. Latency is now pushed to 2 cycles (1 for hash, 1 for memory read).

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v004/ha_tff_bram_bank.v` 

## Emotional Engineering State
- **Memory Confidence**: 80% (BRAM inference is usually standard).
- **Verification Confidence**: 2% (I am flying blind).
- **Overall Architecture**: 40%.

## Alternative Solutions & Failed Branches
I considered trying to build a TCAM out of LUTs, but after reading Xilinx App Notes, I realized the routing congestion would be catastrophic. 

## Engineering Debt Register
- **Verification Debt**: STILL writing RTL without testbenches. This is going to bite me.
- **Control Plane Debt**: I have no way to populate the BRAMs dynamically.

## Next Objectives
- I need to write the Cuckoo Matcher, which takes the 4 outputs from these BRAMs and compares them against the original parsed tuple to see if we have a match.
