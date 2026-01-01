# Cuckoo Hashing in Hardware

## The Firewall Problem
I need to check if an incoming packet's IP/Port tuple matches a "Drop" rule.
If I have 10,000 rules, I can't loop through an array. A loop takes 10,000 clock cycles. I need an Exact-Match lookup that resolves in 1 clock cycle.

## TCAM vs RAM
- **TCAM (Ternary Content Addressable Memory):** You input the data, and it outputs the address. It searches everything in parallel. It is incredibly fast, but astronomically expensive and consumes massive power. The Artix-7 does not have TCAM.
- **SRAM (Block RAM / BRAM):** You input the address, it outputs the data. The Artix-7 has plenty of BRAM.

## How to use RAM for Exact Match? (Hash Tables)
If I hash the IP/Port tuple, I get an address. I look up that address in BRAM. 
But what about collisions? (Two different IPs producing the same hash).
In software, we use linked lists (chaining). In hardware, a linked list requires variable clock cycles to traverse. This breaks determinism.

## The Cuckoo Hashing Solution
Instead of 1 hash function, use 4 independent hash functions.
Instead of 1 BRAM, use 4 independent BRAM banks.

When a packet arrives, I calculate all 4 hashes simultaneously (using parallel combinatorial logic).
I query all 4 BRAMs simultaneously.
If *any* of the 4 banks return a match, the packet is dropped.
This guarantees exactly 1 clock cycle for lookup.

## The Hash Algorithm
Standard hashes (like CRC32 or MurmurHash) require multiplication or complex XOR shifts, burning LUTs.
For my IP/Port tuple (104 bits), I will use **XOR Folding**. I will slice the 104 bits into smaller chunks and XOR them together in different permutations to generate the 4 unique indices. It costs almost zero logic.
