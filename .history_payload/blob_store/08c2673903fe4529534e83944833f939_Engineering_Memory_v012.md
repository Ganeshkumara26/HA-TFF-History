# Engineering Memory - Iteration 012 (Week 12)

## Research Direction & Goals
**Current Goal**: Achieve absolute timing closure and fix the pipeline misalignment.

## Knowledge Boundaries
**Things I understand:**
- Pipelining is the answer to everything in FPGA design. By breaking the SNN arithmetic into two stages (`ADR-012`), I slashed the critical path in half.
- If you delay data, you must delay *all* parallel paths identically.

**Things I suspect / believe:**
- I believe the project is essentially complete from an RTL hardware perspective. `TIM-012` shows a WNS of +0.517ns. 

**Things I do not understand:**
- I still have immense Research and Control Plane debt. The AI weights are hardcoded. The firewall rules are static hex files. This is not a commercial product, it's a university prototype.

## Architecture & Math
See `ARCH-v012`. The mathematical alignment of the pipelines is a thing of beauty. The Cuckoo Hash takes 4 cycles. The SNN takes 5 cycles. We add a 1-cycle delay to the Cuckoo output, and both arrive exactly at Cycle 6 (relative to word 4) to be ANDed together.

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v012/snn_tff_neuron_v004.v`
- **Testbench**: `TB-012` proves the alignment. 
- **Synthesis**: `TIM-012` proves timing closure at 156.25 MHz.

## Emotional Engineering State
- **Overall Confidence**: 100%. I actually did it. The datapath works.

## Alternative Solutions & Failed Branches
The unpipelined SNN (`v011`) is dead. It violated physics. 

## Engineering Debt Register
- **Resolved**: Timing Debt is gone. Verification Debt is gone (I wrote the testbenches!). Pipeline Alignment Debt is gone.
- **Remaining**: Documentation, Control Plane, Research.

## Next Objectives
- Write the Final Takeaway Report and prepare for grading.
