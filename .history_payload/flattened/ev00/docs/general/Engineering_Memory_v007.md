# Engineering Memory - Iteration 007 (Week 7)

## Research Direction & Goals
**Current Goal**: Translate the mathematical LIF model from `ARCH-v006` into physical Verilog logic.
**Previous Goal**: Architecture pivot to SNNs.

## Knowledge Boundaries
**Things I understand:**
- I can use a combinatorial tree of adders to sum the synaptic weights without needing multipliers. (See `ARCH-v007`).
- I decided on a Shallow Fully Connected topology to save logic area. (`ADR-007`).

**Things I believe:**
- I believe Verilog's `signed` keyword will handle all the 2's complement math automatically. I just declared `reg signed [15:0] membrane_u` and assumed it works.

**Things I do not understand:**
- How do I handle negative spikes? Do spikes have negative weights? I assume yes (inhibitory connections).

## Architecture & Math
See `ARCH-v007`. We established the `current = sum(w[i] * spike[i])` model. To avoid BRAM usage for now, I hardcoded the weights as `assign` wires (`w0[0] = 50`, `w0[1] = -100`, etc.).

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v007/snn_tff_neuron_v001.v` and `snn_tff_layer_v001.v`.

## Emotional Engineering State
- **SNN RTL Confidence**: 80% (The code compiled in my head).
- **Verification Confidence**: 0% (I am flying blind).
- **Overall Architecture**: 50%.

## Alternative Solutions & Failed Branches
Considered a deep Convolutional Spiking Network, but abandoned it due to the requirement of buffering entire 1500-byte packets. Documented in `ADR-007`.

## Engineering Debt Register
- **RTL Debt**: Hardcoded weights in `snn_tff_layer_v001.v`. (Tracked in `Q004`).
- **Verification Debt**: STILL writing RTL without testbenches.

## Next Objectives
- I finally need to simulate this. I have a terrible feeling that my Verilog signed math is wrong.
