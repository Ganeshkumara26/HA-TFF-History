# Pseudo-Commit: ENG-0006 (Literature Review: Spiking Neural Networks for NIDS)

## Motivation
With the rule-based Datapath (HA-TFF) meeting timing constraints for 10Gbps line-rate, the base infrastructure is complete. The system can successfully drop known threats (via the Cuckoo Hash Table) at wire speed. However, zero-day attacks and distributed anomalies (like DDoS or Slow-Loris) cannot be caught by static exact-match rules.

The project requires an advanced heuristic engine. Standard Deep Neural Networks (DNNs) consume immense DSP and BRAM resources, limiting their scalability on edge FPGAs. Spiking Neural Networks (SNNs) offer a promising alternative by modeling biological neurons. They communicate via binary spikes over time, replacing dense multiplication operations with multiplexing or simple accumulation.

## Current Understanding
- A rule-based firewall is a 1-to-1 matcher (O(1) lookup).
- Anomaly detection requires looking at traffic statistics over a time window.
- Spiking Neural Networks naturally integrate temporal information.
- A standard Leaky Integrate-and-Fire (LIF) neuron integrates incoming spikes, leaks charge over time, and fires an output spike if the membrane potential exceeds a threshold.

## Hypothesis
We can extend the HA-TFF by adding an SNN coprocessor (SNN-TFF). The SNN will monitor packet headers (encoded as spikes) and identify malicious patterns. If the output neuron fires, it asserts a "Drop" signal, overriding the default behavior.

## Literature Findings

### Paper 1: SNNs for Network Intrusion Detection (NIDS)
- **Concept**: Encoding network features (packet size, protocol, inter-arrival time) into spike trains using Rate Coding or Temporal Coding.
- **Pros**: Extreme energy efficiency on neuromorphic hardware and FPGAs.
- **Cons**: Difficult to train compared to standard DNNs (due to non-differentiable spike functions).

### Paper 2: Hardware-Efficient LIF Neurons on FPGA
- **Concept**: Using bit-shifts instead of division for the "leak" factor, and integer arithmetic for the membrane potential.
- **Pros**: Maps perfectly to FPGA logic. A single LIF neuron requires zero DSP slices.
- **Cons**: Precision loss due to integer rounding, but acceptable for binary classification tasks (Threat vs Safe).

## Next Experiments
- Formulate the mathematical basis for an FPGA-friendly LIF neuron without floating-point math.
- See `03_Math/LIF_Neuron_Formulation.md`.

## Remaining Issues
- We need to determine how to route packet metadata from the parser into the SNN. The parser extracts the 5-tuple; we might need to extract payload length or packet inter-arrival time to feed the SNN.
