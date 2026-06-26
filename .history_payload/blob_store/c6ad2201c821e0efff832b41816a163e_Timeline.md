# Master Engineering Timeline

This document tracks my transition from hardware/software integration to custom FPGA digital design over a 6-month period.

## Pre-Internship (Jan - Apr 2026)
- **Focus:** Foundations in Linux Networking, Verilog basics, and Digital Logic.
- **Milestone:** Acquired theoretical knowledge of FPGA architectures (LUTs, FFs, BRAMs) but lacked practical application. (See *Vol0_Foundations*).

## Internship Phase (May 2026)
- **Focus:** MeghDut Hardware-Software Integration & Benchmarking.
- **Milestone:** Teammates built the Node.js/React software stack. My role was protocol writing (MAVLink over MQTT) and stress-testing the integration between the ESP32 hardware and the backend.
- **Realization (May 25 onwards):** Discovered that the software parser couldn't keep up with high-frequency telemetry bursts without suffering non-deterministic GC pauses. Began formal bottleneck analysis to justify hardware offloading. (See *Vol1_MeghDut_Learning*).

## Physical Implementation (June - October 2026)
- **Focus:** HA-TFF Project.
- **Milestone:** By early June, the offloading strategy was finalized. Began building the hardware datapath. Built a 64-bit word-aligned parser and a BRAM-based Cuckoo Hashing table. Closed timing at 156.25 MHz. 
- **Evolution:** Realized static exact-match tables are blind to zero-day threats. Extended the datapath with a Spiking Neural Network (SNN) anomaly detector (Traffic Filter Firewall) without using DSP slices. (See *Engineering_History*).

## Capstone & Reflection (Nov - Dec 2026)
- **Focus:** Documentation and future roadmap.
- **Milestone:** Completed the engineering archive. (See *Vol3_Capstone*).
