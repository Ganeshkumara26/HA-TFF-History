# ADR-010: Combinatorial Output Merge

**Status:** Superseded (by ADR-011)
**Date:** Week 10 (v010)

## Context
The Datapath generates a `dp_action_forward` signal. The SNN Coprocessor generates an `anomaly_detected` signal. We must combine these to make the final `m_axis_tvalid` firewall decision.

## Options Considered

### Option A: Combinatorial AND
`assign final_forward = dp_action_forward && !anomaly_detected;`
- **Pros:** Zero added latency.
- **Cons:** (PHYSICS FIRST). This AND gate sits at the end of two massive, independent logic clouds. The Datapath path traverses BRAM routing and a 104-bit Matcher. The SNN path traverses adders and a 16-bit threshold comparator. Merging them unpipelined creates an enormous critical path.

### Option B: Pipelined Output Register
`always @(posedge clk) final_forward <= dp_action_forward && !anomaly_detected;`
- **Pros:** Breaks the critical path.
- **Cons:** Adds 1 cycle of latency. Also requires ensuring the SNN and Datapath are cycle-aligned before registering.

## Decision
**Option A (Combinatorial AND)** is selected for initial prototype `v002`.

## Engineering Justification
I chose Option A because I was lazy and didn't want to calculate the pipeline alignments. I assumed the Artix-7 was fast enough to handle one extra AND gate. 
**Result:** Synthesis `SYNTH-010` FAILED timing with a Worst Negative Slack (WNS) of `-0.465ns`. The assumption was completely incorrect.

## Dependencies
- **Implements:** System Integration
- **Creates:** `RTL-v010/ha_tff_system_top_v002.v`
- **Verified By:** `TIM-010` (Timing Failed)
