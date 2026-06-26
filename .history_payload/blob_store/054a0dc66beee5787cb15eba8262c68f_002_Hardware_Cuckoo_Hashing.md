# Literature Summary: Hardware Cuckoo Hashing for Firewalls

## Date: 2026-01-09
## Author: Student Engineer

### Concept
To match the 5-tuple (104 bits) against a massive list of rules at wire speed (156.25 MHz), standard hash tables risk collisions. A collision in a standard hash table requires iterating through a linked list or linear probing, which introduces variable latency. Variable latency breaks the deterministic pipeline requirement of high-speed FPGAs.

### The Cuckoo Hashing Algorithm
Cuckoo hashing uses multiple hash functions and multiple tables (banks). 
For a 4-way Cuckoo Hash:
1. An incoming 5-tuple $x$ is hashed by 4 independent hash functions: $h_1(x), h_2(x), h_3(x), h_4(x)$.
2. These generate 4 possible indices in 4 distinct memory banks (Block RAMs).
3. The lookup process simply reads all 4 memory banks simultaneously. If any bank matches the 5-tuple, the rule is found.
4. Lookup time is exactly $O(1)$ memory read latency.

### FPGA Adaptation (Category C Reasoning)
- **Data Plane (Fast Path)**: The FSM only needs to compute the 4 hashes and read the BRAMs. This can easily be pipelined to 1 clock cycle for hashing and 2 clock cycles for BRAM reads.
- **Control Plane (Slow Path)**: When the software adds a new rule, it tries to place it in bank 1. If occupied, it kicks out ("cuckoos") the existing entry to its alternative bank. This insertion process might take multiple cycles, but since it's done by the control plane, it does not interrupt the 10GbE data plane.

### Candidate Hash Functions
- **CRC32**: Standard, but consuming 104 bits of data in 1 cycle requires a massive XOR tree.
- **SipHash**: Cryptographically strong, but heavily serialized.
- **Pearson Hash**: Too simple, poor avalanche for IPs.
- **Parametrized Multiplicative / XOR Hash (Jenkins or custom)**: Fast, single-cycle combinatorial logic.

### Next Steps
Explore a mathematical model to ensure that a 4-way Cuckoo Hash provides sufficient load factor (occupancy) before insertion failures occur.
