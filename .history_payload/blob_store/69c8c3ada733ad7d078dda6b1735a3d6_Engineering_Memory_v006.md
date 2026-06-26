# Engineering Memory - Iteration 006 (Week 6)

## Research Direction & Goals
**Current Goal**: Pivot the architecture to include AI anomaly detection because static rules are blind to zero-day threats.
**Previous Goal**: Build the exact-match datapath.

## Knowledge Boundaries
**Things I understand:**
- Standard Neural Networks (DNNs/CNNs) use floating-point Multiply-Accumulates (MACs). 
- My FPGA has 240 DSP slices. I can't build a fast, wide DNN with that.

**Things I suspect / believe:**
- I read some papers on Neuromorphic computing. Spiking Neural Networks (SNNs) use binary spikes (1 or 0). 
- I believe that if I use SNNs, I don't need multipliers. I just need adders. This is mathematically proven in `ARCH-v006`.

**Things I do not understand:**
- How do I turn an Ethernet packet into a "spike"? SNNs usually operate on time-series data (like event cameras). Networking packets are bursty payloads. 

## Architecture & Math
See `ARCH-v006` for the discretized Euler approximation of the LIF equation. We use an arithmetic right shift (`>>>`) to simulate the membrane leak, reducing hardware cost to literally zero LUTs for the division. 

## Evidence IDs & Cross-Referencing
- **ADR**: `ADR-006` (SNN vs DNN).

## Emotional Engineering State
- **SNN Confidence**: 20% (The math makes sense, but I've never written an AI in Verilog).
- **Verification Confidence**: 0% (Still terrible).
- **Overall Architecture**: 50% (The hybrid concept is amazing, if I can pull it off).

## Alternative Solutions & Failed Branches
Considered an 8-bit integer MLP (Multi-Layer Perceptron). Even with 8-bit quantization, the multiplier arrays would consume massive routing resources and create pipeline stalls. (Documented in `ADR-006`).

## Engineering Debt Register
- **Research Debt**: Huge. I have no idea how to train this SNN yet.
- **Pipeline Alignment Debt**: Still ignoring the fact that my payload is leaking past the firewall decision point.

## Next Objectives
- Write the actual Verilog RTL for the LIF neuron and a fully connected SNN layer.
