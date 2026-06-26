# Project Evolution

How my focus shifted logically from a high-level web dashboard to a low-level silicon anomaly detector.

1. **MeghDut (Software System)**
   - *Scope:* Drone fleet telemetry visualization.
   - *Outcome:* Identified that scaling telemetry parsing in Node.js is inherently non-deterministic.

2. **Packet Processing Pipeline (Conceptual)**
   - *Scope:* Offloading UDP/TCP header extraction from CPU to FPGA.
   - *Outcome:* Realized that once the packet is in hardware, we can filter it natively before it hits the CPU.

3. **Hardware Traffic Filter Firewall (HA-TFF Datapath)**
   - *Scope:* Exact-match IP/Port filtering using Cuckoo Hashing.
   - *Outcome:* Achieved deterministic dropping of known bad packets at 10Gbps line rate. 

4. **Spike-based Traffic Filter Firewall (SNN-TFF Extension)**
   - *Scope:* Behavioral threat detection using neuromorphic computing.
   - *Outcome:* Integrated an SNN alongside the Cuckoo datapath to flag anomalous, zero-day telemetry behavior without exhausting DSP resources.
