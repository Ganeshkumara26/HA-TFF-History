# Engineering Memory: MeghDut Integration v005 (The Hardware Pivot)

## Context (End of May 2026)
The integration phase of my internship is complete. I successfully built the Python and ESP32 bridges to extract MAVLink via OTG, UDP, TCP, and pipe it into the MQTT broker. The teammates' React dashboard works.

However, the `v004` benchmark fundamentally changed my trajectory.

## The Architectural Flaw
Software processing of raw telemetry is inherently vulnerable to DoS and non-deterministic latency. 
If an attacker sends 1 million invalid packets, the Node.js server still has to context switch, parse the JSON, perform a Set lookup (`approvedDronesCache.has(droneId)`), and then drop the packet. This exhausts the CPU and blocks valid telemetry.

## The Proposed Solution: Hardware-Accelerated Traffic Filter Firewall
We need a "poor man's SmartNIC". We need to intercept the Ethernet frames *in hardware* before they generate an interrupt to the CPU.

My proposal:
1. Tap the physical Ethernet line using an FPGA.
2. Build a Verilog state machine to parse the UDP/TCP headers on an AXI-Stream bus.
3. Perform an exact-match lookup on the IPs and Ports using a Cuckoo Hash table in BRAM.
4. Physically drop unauthorized packets in 1 clock cycle.
5. Only pass valid packets to the Linux Kernel / Node.js backend.

## Transition to Volume 2
Starting in June, my internship ends and my independent research begins. I will learn the prerequisites (Vol0) and begin physically designing the Traffic Filter Firewall datapath in Verilog (Vol2).
