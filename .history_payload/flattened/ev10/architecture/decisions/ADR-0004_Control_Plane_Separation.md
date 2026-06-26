# Architecture Decision Record: ADR-0004

## Title
Separation of Datapath Lookup from Control Plane Insertion for the Cuckoo Hash Table

## Date
2026-01-10

## Status
Accepted

## Context & Problem
A Cuckoo Hash Table relies on an insertion process that must occasionally evict ("cuckoo") existing entries to alternate banks. If a rule is inserted into Bank 0 but an existing rule is already there, the existing rule is moved to its alternative bank (e.g., Bank 1). If Bank 1 is full, its occupant is moved, and so on. This process can theoretically loop infinitely if the table is over capacity, requiring a rehash. 
Implementing this complex, non-deterministic graph-walking algorithm in FPGA fabric (RTL) requires deep state machines and complicates timing. Meanwhile, the Datapath strictly requires fixed-latency (O(1)) rule lookups to sustain 10Gbps line rate.

## Engineering Question
Should the FPGA Datapath implement both rule lookup and rule insertion, or should rule insertion be offloaded to a software Control Plane?

## Options

### Option A: Fully Integrated Hardware Hash Table
- **Advantages**: The FPGA is completely self-sufficient. New rules can be injected directly via a packet side-channel.
- **Disadvantages**: The RTL state machine for evictions is massive. Furthermore, resolving infinite loops (rehashing) requires pausing the 10GbE datapath or dropping packets, which violates the strict latency requirement of the HA-TFF.

### Option B: Separated Control Plane / Data Plane Architecture
- **Advantages**: The FPGA RTL is purely dedicated to reading the BRAMs (Fast Path). The host CPU (e.g., MicroBlaze, Zynq ARM, or PCIe Host) calculates the hash locations in software, performs the eviction walk, and writes the final configuration to the FPGA BRAMs via an AXI-Lite interface. 
- **Disadvantages**: Requires software drivers. Requires True Dual Port BRAMs where Port A is read-only (Datapath) and Port B is write-only (Control Plane).

## Decision
Choose **Option B**: Separate the Control Plane from the Datapath.

## Reason
Control plane separation is the gold standard for SDN (Software Defined Networking) switches (like P4 architectures). The host CPU is perfectly suited to handle the complex graph theory of Cuckoo hashing, while the FPGA remains a purely deterministic, low-latency pipeline. We will use True Dual Port BRAMs to allow simultaneous access.

## Future Implications
The RTL will only implement the read-side of the Cuckoo Hash Table. For verification, we must write a Python script (`cuckoo_place.py`) to simulate the Control Plane: it will compute the hashes, place the rules into memory banks, and generate `.mem` files that the Verilog `$readmemh` function can load during simulation.
