# Engineering Memory - Iteration 010 (Week 10)

## Research Direction & Goals
**Current Goal**: Wire the exact-match Datapath and the SNN Anomaly detector together and run a full system test.

## Knowledge Boundaries
**Things I understand:**
- Vivado is ruthless. If your testbench doesn't toggle an input, Vivado will delete your entire architecture via Dead Code Elimination. (`BUG-005`).

**Things I suspect / believe:**
- I suspected that merging the two architectures with a simple combinatorial AND gate was a bad idea, but I tried it anyway to avoid math. 

**Things I do not understand:**
- Now that timing has failed (`-0.465ns`), I don't actually know if the critical path is strictly the AND gate, or if the SNN logic itself is too slow.

## Architecture & Math
See `ARCH-v010`. The mathematical model for the critical path shows that `T_logic + T_routing > 6.4ns`. The system violates physics. (See `ADR-010`).

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v010/ha_tff_system_top_v002.v` 
- **Synthesis**: `SYNTH-010`
- **Timing Report**: `TIM-010` (Provides physical evidence of the `-0.465ns` failure).
- **Testbench**: `TB-010` (Finally wrote a real testbench!).

## Emotional Engineering State
- **Overall Architecture**: 80% (It functionally works!).
- **Verification Confidence**: 60% (The simulation waveform `SIM-010` looks beautiful. Packets are parsed, SNN spikes, traffic drops).
- **Timing Confidence**: 0% (Failed constraints).

## Alternative Solutions & Failed Branches
The combinatorial top-level merge is officially a failed branch. It exists in `v010`, but it will be replaced in `v011`. 

## Engineering Debt Register
- **Timing Debt**: System fails at 156.25 MHz.
- **Pipeline Alignment Debt**: Looking closely at the waveform from `SIM-010`, the `anomaly_detected` flag goes high, but the actual payload `s_axis_tdata` just passes straight through combinatorially! The firewall is deciding to drop a packet 4 cycles *after* the packet already entered the network.

## Next Objectives
- Write a delay line (Shift Register) to hold the payload data in a buffer until the firewall decision is ready.
- Add a pipeline register to the system output to fix the timing violation.
