# ADR-0005: Matcher Pipelining for Timing Closure

## Context
During Iteration 006 (Vivado synthesis of the Datapath `v004`), timing analysis revealed a Worst Negative Slack (WNS) of -0.350ns against a 156.25 MHz clock (6.4ns period) on the `xc7a100tcsg324-1` Artix-7 device.

The critical path spans 12 logic levels. It starts at the BRAM output (`read_data_reg`) of Bank 0 and ends at the Matcher's `match_found_reg`. The delay is caused by the massive 104-bit combinatorial equality check ($A == B$) across four banks running in parallel, followed by a wide OR-reduction to determine if *any* bank matched.

## Options

### Option A: Lower the Clock Frequency
We could lower the core clock to 125 MHz (8.0ns).
- **Advantages**: No RTL changes required. Immediate timing closure.
- **Disadvantages**: A 125 MHz clock on a 64-bit wide datapath yields only $125M \times 64 = 8$ Gbps of throughput. This fails the core 10 Gbps line-rate requirement.

### Option B: Pipeline the Matcher (Two Stages)
We can split the Matcher logic across two clock cycles.
- Stage 1: Perform the four independent 104-bit equality checks and register the results (`bank0_match`, `bank1_match`, etc.) along with the extracted actions.
- Stage 2: Perform the OR-reduction to compute `match_found` and multiplex the correct `action_forward`.
- **Advantages**: Breaks the 12-level logic chain in half. Easily meets 6.4ns timing on Artix-7.
- **Disadvantages**: Increases total datapath latency by 1 clock cycle (from 3 cycles to 4 cycles). This is acceptable since throughput (1 packet per cycle) remains unaffected.

## Decision
**Select Option B.** We will pipeline the `ha_tff_matcher` into a 2-stage architecture (`ha_tff_matcher_v002.v`).

## Future Implications
The overall latency of the HA-TFF datapath increases to 4 clock cycles:
1. Hash Computation (Cycle 1)
2. BRAM Address Setup & Read (Cycles 2 & 3)
3. Matcher Equality Check (Cycle 4)
4. Matcher Reduction & Output (Cycle 5 - wait, 1 hash + 2 BRAM + 2 Match = 5 cycles total latency from valid 5-tuple).
Throughput remains strictly O(1) at 10 Gbps.
