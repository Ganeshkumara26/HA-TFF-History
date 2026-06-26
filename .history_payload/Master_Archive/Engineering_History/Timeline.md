# HA-TFF Project Timeline

This timeline maps the chronological evolution of the Hardware-Accelerated Traffic Filter Firewall across a 12-week (6-month equivalent academic) timeline.

## Phase 1: The Datapath Foundation
- **Week 1 (v001):** Designed initial 8-bit parser FSM. Failed physical constraints (requires 1.25GHz).
- **Week 2 (v002):** Pivoted to 64-bit word-aligned parser to meet 156.25 MHz clock constraint.
- **Week 3 (v003):** Implemented Cuckoo Hash algorithm using combinatorial XOR folding to avoid CRC LUT bloat.
- **Week 4 (v004):** Instantiated True Dual-Port Block RAM (BRAM) arrays for the firewall rule database.
- **Week 5 (v005):** Integrated the Datapath. Pipelined the Cuckoo Matcher to prevent severe logic depth failures. Datapath latency stabilized at 4 cycles.

## Phase 2: The Anomaly Pivot
- **Week 6 (v006):** Recognized static exact-match rules are insufficient for zero-day threats. Pivoted to include a Spiking Neural Network (SNN) coprocessor.
- **Week 7 (v007):** Designed the fully connected SNN layer and the baseline Leaky Integrate-and-Fire (LIF) neuron mathematics.
- **Week 8 (v008):** Debugged catastrophic Verilog signed arithmetic errors (`BUG-003`, `BUG-004`). Enforced strict `16'sd` typing.
- **Week 9 (v009):** Implemented the static Feature Encoder to translate 104-bit tuples into 8-bit binary spike trains.

## Phase 3: System Integration & Closure
- **Week 10 (v010):** Top-level system integration. Synthesis failed (`WNS = -0.465ns`). Discovered massive routing and logic depth issues with the unpipelined output merge.
- **Week 11 (v011):** Implemented the AXI-Stream Data Delay Line to fix payload leakage. Top-level timing still failed (`WNS = -0.400ns`) due to the SNN arithmetic critical path.
- **Week 12 (v012):** Broke the SNN adder into a 2-stage pipeline, extending SNN latency to 5 cycles. Aligned the Datapath with a 1-cycle delay. Achieved absolute timing closure (`WNS = +0.517ns`).
