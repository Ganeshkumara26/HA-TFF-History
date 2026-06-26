# Architecture Decision Record: ADR-0001

## Title
Pivot from Telemetry Parsing to Hardware-Accelerated Traffic Filter Firewall (HA-TFF)

## Date
2026-01-06

## Status
Accepted

## Context & Problem
The initial project direction aimed to accelerate the MAVLink telemetry ingestion of the MeghDut drone ecosystem by building a custom FSM parser on an FPGA. While parsing is a bottleneck, observation of the software architecture reveals a more severe concern: **Security**. The current software stack processes telemetry *after* packets reach the host via the 10GbE network interface. If malicious packets or spoofed commands flood the interface, the host CPU will be overwhelmed, bypassing any software firewall.

## Engineering Question
Should the project remain narrowly focused on a telemetry parser, or generalize into an active packet-filtering engine on the hardware datapath?

## Options

### Option A: Continue Telemetry Parser
- **Advantages**: Simpler RTL, known fixed-length payload (mostly), direct integration with MeghDut's `HardwareGateway.js`.
- **Disadvantages**: Does not protect the host from network-level denial-of-service or spoofing. Narrow scope limits thesis impact.

### Option B: Generalize to Hardware-Accelerated Traffic Filter Firewall (HA-TFF)
- **Advantages**: Protects the entire drone fleet by enforcing drop/forward policies at wire-speed (line-rate). Operates on standard Ethernet/IP/UDP headers, making the architecture universally applicable to high-speed networking.
- **Disadvantages**: Requires parsing standard (and potentially variable-length) network protocols. Requires implementing a hardware hash table (e.g., Cuckoo Hash) for rule matching, which introduces significant complexity and area utilization.

## Decision
Choose **Option B**: Pivot to building the HA-TFF.

## Reason
The broader architecture naturally encompasses telemetry protection while also enabling strict security enforcement. Moving packet filtering into FPGA hardware guarantees deterministic latency and line-rate throughput, completely shielding the software stack from malicious volumetric traffic.

## Future Implications
The RTL must now parse standard Ethernet II, IPv4, and UDP frames instead of custom binary payloads. The next immediate milestone is to implement a 5-tuple extractor capable of identifying the Source/Dest IPs and Ports. Subsequent milestones will require designing a hardware hash function and a Cuckoo Hash Table for rule lookups.
