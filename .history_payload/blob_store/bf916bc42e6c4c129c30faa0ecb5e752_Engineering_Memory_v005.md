# Engineering Memory - Iteration 005 (Week 5)

## Research Direction & Goals
**Current Goal**: Stitch the Parser, Hash, and BRAMs together and write the Matcher logic to determine if we drop or forward a packet.
**Previous Goal**: Build the BRAM arrays.

## Knowledge Boundaries
**Things I understand:**
- I can instantiate modules and wire them up. 
- The latency across the modules stacks up sequentially.

**Things I believe:**
- I originally thought I could just write one giant `always @(*)` block in the matcher to compare the 4 BRAM outputs and pick the winner.
- I now realize (after drafting the math) that this would create a massive routing nightmare. (See `ADR-005`).

**Things I do not understand:**
- What happens if the packet payload data (`s_axis_tdata`) arrives *while* I am still looking up the 5-tuple in the firewall? It takes 4 cycles to make a decision. The payload is going to just pass right through my datapath before I know if I should drop it! 

## Architecture & Math
See `ARCH-v005`. The mathematical model proves that our decision latency is exactly 4 clock cycles (25.6 ns). This is incredible. 

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v005/ha_tff_datapath_top_v002.v` 
- **ADR**: `ADR-005` (Pipelined Matcher).

## Emotional Engineering State
- **Overall Datapath Confidence**: 60% (The logic is sound).
- **Verification Confidence**: 0% (I am terrified of writing the simulation for this).
- **Timing Confidence**: 50% (I think pipelining the Matcher saved me, but I need to run Vivado).

## Alternative Solutions & Failed Branches
I started writing `matcher_unpipelined_v001.v` but deleted it half-way through when I realized comparing 416 bits (4 * 104) and multiplexing the result in a single cycle was a terrible idea. I documented this failure in `05_RTL/Discarded/historical/matcher_unpipelined_v001/`.

## Engineering Debt Register
- **Pipeline Alignment Debt**: Major issue discovered today. The payload is not buffered. If the firewall takes 4 cycles to decide to drop, the first 4 cycles of the payload will have already leaked out the other side.
- **Verification Debt**: Critical.

## Next Objectives
- I absolutely MUST write a testbench for this. I cannot go any further without seeing waveforms.
