# Mathematical Model: Cuckoo Hash Collision Probability

## Date: 2026-01-09
## Author: Student Engineer

### Objective (Category B)
Estimate the load factor and collision probability of a $k$-way Cuckoo Hash Table to size the BRAMs for the HA-TFF.

### Variables
- $N$: Number of rules to store (e.g., 10,000)
- $k$: Number of independent hash functions / memory banks
- $M$: Total number of slots across all banks ($M = k \times \text{bank\_size}$)
- $\alpha$: Load factor ($\alpha = N / M$)

### Mathematical Derivations
For $k = 2$, the maximum theoretical load factor before an insertion loop (a cycle of evictions) occurs is $\approx 50\%$. If we want to store 10,000 rules, we would need 20,000 slots.
For $k = 4$, the maximum load factor approaches $\approx 97\%$. We could store 10,000 rules in just $\sim 10,300$ slots.

### Implementation Constraints
An FPGA BRAM (Block RAM) typically holds 36Kb.
If a firewall rule consists of:
- 5-tuple (104 bits)
- Action: Drop/Forward (1 bit)
- Priority/Metadata: 23 bits
Total entry size: 128 bits.

A standard Xilinx BRAM (36Kb) can be configured as $512 \times 72$ bits or $1024 \times 36$ bits. We can gang them together to get $1024 \times 128$ bits (requires 4 BRAM tiles per bank).

### Target Sizing
- $k = 4$ banks.
- Bank size = 4096 entries (requires 16 BRAM tiles per bank).
- $M = 16,384$ total slots.
- Max capacity at $97\%$ load factor $\approx 15,892$ rules.

### Hash Function Latency
Let $H(x)$ be the hash computation. To meet 156.25 MHz ($T = 6.4$ ns):
The critical path is the XOR tree for hashing 104 bits into 12 bits (since $2^{12} = 4096$).
A 104-bit to 12-bit XOR tree has a depth of $\approx \log_2(104/12) = 4$ LUTs.
4 LUTs delay $\approx 0.8$ ns. 
Conclusion: The hash can easily be computed in a single combinatorial clock cycle.

### Outcome
We will proceed with a 4-way Cuckoo Hash Table. The datapath will compute 4 hashes in parallel (Cycle 1), and issue reads to 4 BRAM banks (Cycle 2).
