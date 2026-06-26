# Engineering Memory - Iteration 008 (Week 8)

## Research Direction & Goals
**Current Goal**: Fix the catastrophic mathematical bugs in the SNN neuron.

## Knowledge Boundaries
**Things I understand:**
- Verilog is incredibly dangerous when mixing signed and unsigned variables. (See `BUG-004`).
- LIF neurons must leak continuously, not just when input data is valid. (See `BUG-003`).

**Things I suspect / believe:**
- I believe my explicit `16'sd` casting rule (`ADR-008`) will finally make the SNN stable. 

**Things I do not understand:**
- I still don't have the Feature Encoder. The SNN is mathematically sound now, but I have no way to connect it to the Datapath parser.

## Architecture & Math
See `BUG-004` for the mathematical explanation of why `-10` became `65526` and ruined the network. 

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v008/snn_tff_neuron_v003.v` 
- **Bug Reports**: `BUG-003`, `BUG-004`

## Emotional Engineering State
- **SNN Confidence**: 90% (The hard lessons of Verilog types have been learned).
- **Verification Confidence**: 20% (Wrote tiny unit tests to find these bugs).
- **Overall Architecture**: 55%.

## Alternative Solutions & Failed Branches
I considered replacing the `THRESHOLD` parameter with an input wire driven by a control plane (AXI-Lite), but decided against it to save time. It remains a parameter.

## Engineering Debt Register
- **RTL Debt**: Hardcoded SNN weights (`Q004`).
- **Feature Gap**: The SNN is floating in isolation. I must build the Feature Encoder.

## Next Objectives
- Write the Feature Encoder to translate the Parser's 104-bit tuple into 8 discrete spikes.
