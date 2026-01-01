# Hardware/Software Partitioning

## The Partitioning Dilemma (Late May 2026)
By late May, my integration benchmarks proved we have a scaling gap. 
If an attacker sends massive bursts of invalid telemetry, the Node.js server wastes CPU cycles parsing the JSON and checking the pprovedDronesCache before dropping the packet.

## The Recommendation
- **Software (Node.js):** My teammates' code is perfect for the REST API and the WebSocket management. It should only handle *valid*, authenticated telemetry.
- **Hardware (NIC/FPGA):** We need to intercept raw Ethernet frames *before* they hit the CPU. It should perform exact-match lookups on the IPs/Ports/DroneIDs and physically drop unauthorized packets at line rate.
