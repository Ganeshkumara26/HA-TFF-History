# Architecture Decision Record: ADR-0003

## Title
Adoption of a 4-Way Cuckoo Hash Table for Hardware Rule Lookup

## Date
2026-01-09

## Status
Accepted

## Context & Problem
With the 64-bit HA-TFF parser successfully extracting the 104-bit 5-tuple from network traffic at 10Gbps, the datapath must now lookup this tuple against a firewall policy table. A standard linear search is $O(N)$ and cannot sustain line-rate processing. A TCAM (Ternary Content Addressable Memory) built from FPGA fabric LUTs is $O(1)$ but consumes an unacceptably large footprint for 10,000+ rules, leading to severe timing violations.

## Engineering Question
Which memory architecture provides deterministic $O(1)$ latency for 10,000+ firewall rules while maintaining high utilization of standard Block RAMs (BRAMs)?

## Options

### Option A: Binary Search Tree over BRAM
- **Advantages**: Standard algorithm. BRAM footprint is small.
- **Disadvantages**: $O(\log N)$ latency. For 16,384 rules, a lookup takes 14 memory cycles. While pipelinable, the logic to handle variable traversal paths at 156.25 MHz is complex.

### Option B: 2-Way Cuckoo Hash Table
- **Advantages**: Exact $O(1)$ lookup time. Uses exactly 2 memory reads per packet.
- **Disadvantages**: The maximum load factor before insertion failures occur is $\approx 50\%$. To hold 10,000 rules, we must provision 20,000 slots, wasting BRAM.

### Option C: 4-Way Cuckoo Hash Table
- **Advantages**: $O(1)$ lookup time (4 parallel memory reads). Achieves $\approx 97\%$ load factor, allowing 15,892 rules to fit tightly in 16,384 slots.
- **Disadvantages**: Requires 4 independent hash functions, increasing the combinational logic depth slightly compared to a 2-way hash. 

## Decision
Choose **Option C**: Implement a 4-Way Cuckoo Hash Table.

## Reason
The 4-way Cuckoo Hash provides the optimal balance. It guarantees deterministic, single-cycle lookup performance (the 4 BRAMs are read in parallel) which is strictly required for the HA-TFF datapath. The mathematical model (Category B evidence) proves that the hash functions (XOR trees reducing 104 bits to 12 bits) will have a delay of only $\approx 0.8$ ns, easily meeting the 6.4 ns clock period.

## Future Implications
The next iteration requires implementing RTL for four unique parameterizable XOR-based hash functions (`ha_tff_hash_v001.v`) and simulating their distribution. We must also design the BRAM interface to instantiate the 4 memory banks.
