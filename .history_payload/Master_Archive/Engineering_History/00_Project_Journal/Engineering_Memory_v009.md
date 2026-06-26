# Engineering Memory - Iteration 009 (Week 9)

## Research Direction & Goals
**Current Goal**: Translate 5-tuples into spikes so the SNN can process them.
**Previous Goal**: Fix the SNN signed math bugs.

## Knowledge Boundaries
**Things I understand:**
- I can use magnitude comparators (`>`) and equality checks (`==`) to generate boolean flags (spikes).
- Hardcoding these values is terrible engineering practice, but necessary for the prototype schedule. (`ADR-009`).

**Things I believe:**
- I believe the SNN path latency is 3 cycles after the parser. (See `ARCH-v009`).

**Things I do not understand:**
- The Exact-Match Datapath decision latency is 4 cycles. The SNN latency is 3 cycles. How am I going to merge these two decisions cleanly without creating timing violations? 

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v009/snn_feature_encoder.v` 
- **ADR**: `ADR-009` 

## Emotional Engineering State
- **Feature Encoder Confidence**: 90% (It's just simple comparators).
- **Integration Confidence**: 20% (The two halves of my project have different latencies).
- **Overall Architecture**: 65%.

## Alternative Solutions & Failed Branches
Abandoned the idea of an AXI-Lite memory-mapped configuration interface. It would take me a month to write the AXI drivers and Linux kernel module. Hardcoded RTL is the only way forward for now.

## Engineering Debt Register
- **Control Plane Debt**: Feature thresholds are permanently baked into silicon. 

## Next Objectives
- The big one: System Integration. Wire the Cuckoo Datapath and the SNN Coprocessor together into `ha_tff_system_top`.
