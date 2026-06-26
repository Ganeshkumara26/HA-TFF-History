# ADR-0006: SNN-Based Anomaly Detection Extension

## Context
With the HA-TFF Datapath reaching 10Gbps timing closure (Iteration 007), the project's baseline network processing engine (Cuckoo Hash matcher) is complete. The overarching MeghDut vision requires detecting complex, distributed anomalies (like DDoS or volumetric attacks) on high-speed telemetry streams. 

A pure rule-based firewall fails against zero-day or rate-based attacks because it only inspects a single packet's headers at a time. We need an intelligent coprocessor that observes traffic over time. While Deep Neural Networks (DNNs) are powerful, their dense multiplication operations consume too much DSP on Edge FPGAs. Spiking Neural Networks (SNNs) communicate via binary spikes over time, replacing multipliers with simple adders and bit-shifts.

## Options

### Option A: Integrate a DNN Coprocessor (MLP/CNN)
- **Concept**: Convert packet headers into 8-bit integer vectors and feed them through a standard Multi-Layer Perceptron (MLP).
- **Advantages**: Standard DL frameworks (PyTorch) export easily.
- **Disadvantages**: The dot products require hundreds of DSP slices. The Artix-7 `xc7a100t` only has 240 DSP slices, which would severely bottleneck the datapath.

### Option B: Integrate an SNN Coprocessor (SNN-TFF)
- **Concept**: Encode network metadata into binary spike trains and feed them through a network of Leaky Integrate-and-Fire (LIF) neurons.
- **Advantages**: As shown in `03_Math/LIF_Neuron_Formulation.md`, a hardware LIF neuron requires zero DSP slices. It operates purely on Adders and Shift registers. This maps perfectly to Artix-7 LUT fabric, leaving DSPs free for other tasks or allowing massive parallelization.
- **Disadvantages**: Requires time-based simulation (running the SNN over $T$ timesteps per inference), which increases latency.

## Decision
**Select Option B.** We will architect an SNN-TFF coprocessor. The firewall datapath will act as a baseline, dropping known bad packets instantly. Unknown packets will trigger the SNN, which analyzes them for malicious signatures. If the SNN detects an anomaly, it asserts a "Drop" override.

## Future Implications
The next RTL iterations must explore:
1. SNN Core: Building `snn_tff_neuron.v` using the shift-leak method.
2. Network Integration: Connecting the SNN to the AXI-Stream parser output.
3. Latency handling: Since the SNN takes $T$ cycles to evaluate, we may need a buffer for packets while they are being inspected.
