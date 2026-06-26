# Engineering Memory - Iteration 003 (Week 3)

## Research Direction & Goals
**Current Goal**: Develop an exact-match lookup mechanism for firewall rules using Cuckoo Hashing.
**Previous Goal**: 64-bit parser (Achieved).

## Knowledge Boundaries
**Things I understand:**
- TCAM (Ternary Content Addressable Memory) is what Cisco uses, but it's way too expensive for my FPGA board. I must use BRAM.
- Standard hash tables suffer from collisions, which ruins fixed latency. 
- Cuckoo Hashing uses multiple hash functions to guarantee O(1) lookup time. (I read a paper on this last night).

**Things I suspect / believe:**
- I believe simple XOR folding will provide enough "randomness" to distribute IP addresses across 4 BRAM banks evenly. (See `Assumption A-003` which I've just logged).

**Things I do not understand:**
- Will an attacker exploit my weak XOR hash? Yes. Do I know how to fix it within the 156.25 MHz timing constraint? No.

## Architecture & Math
See `ARCH-v003`. I mapped out the math for compressing 104 bits into four 12-bit hashes. It boils down to 9-input XOR trees, which map perfectly to 2 levels of LUT6 on the Artix-7.

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v003/ha_tff_hash_v001.v` 
- **ADR**: `ADR-003` explicitly justifies why I chose XOR over CRC32 (LUT footprint and timing constraints).

## Emotional Engineering State
- **Hashing Confidence**: 70% (The logic is written, but I haven't measured the collision rate).
- **Verification Confidence**: 10% (Still haven't written testbenches).
- **Overall Architecture**: 30% (It's starting to look like a real datapath!).

## Alternative Solutions & Failed Branches
I heavily considered writing 4 parallel CRC32 generators. However, based on my understanding of FPGA physics, calculating a 104-bit CRC in a single cycle creates a massive routing net. Doing it 4 times would destroy my timing. Therefore, I didn't even bother writing the CRC RTL. I am logging this as a documented design rejection in `ADR-003` rather than fabricating fake failed code.

## Engineering Debt Register
- **Security Debt**: XOR hashing is highly vulnerable to algorithmic complexity attacks. (Added to tracker).
- **Verification Debt**: STILL haven't simulated `v002` or `v003`. I am building up a massive verification deficit.

## Next Objectives
- I need to actually build the 4 Cuckoo Hash BRAM banks that these hash values will index into.
