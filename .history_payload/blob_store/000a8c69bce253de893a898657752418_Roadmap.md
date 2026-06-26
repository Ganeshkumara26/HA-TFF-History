# Future Work & Research Directions

## 1. True TCP State Tracking
- Currently, the HA-TFF datapath only filters stateless UDP/TCP based on IP and Port. Tracking the TCP handshake (SYN/ACK) in hardware requires a massive state machine. This is a primary target for future work.

## 2. Dynamic SNN Training
- The Spiking Neural Network weights are currently synthesized as hardcoded parameters. Future work should implement an AXI-Lite memory-mapped interface so a MicroBlaze soft-core CPU can dynamically update weights based on backpropagation results from a host PC.

## 3. Publication Roadmap
- Compile the SNN-assisted Traffic Filter Firewall findings into a paper focusing on "DSP-free Neuromorphic Anomaly Detection at 10Gbps".
