# Engineering Memory - Iteration v013

## Focus Area: Resolving Hardcoded AI Weights & Hash Security

### The Problem
The Final Capstone highlighted two major flaws in the hardware prototype:
1. **The AI Weights were ROM:** SNN synaptic weights were strictly hardcoded. We can't update the threat model without recompiling the 10-hour FPGA bitstream.
2. **The Hash was Vulnerable:** The Cuckoo hash XOR folding used static magic numbers, making the Firewall extremely vulnerable to Algorithmic Complexity Attacks (where an attacker crafts specific packet headers to cause 100% hash collisions).

### Try & Fail #1: SipHash for Security
- **Try:** My first instinct was to implement SipHash, the industry standard for preventing hash collision attacks in software.
- **Fail:** Hardware reality hit me hard. SipHash requires multiple rounds of complex 64-bit additions, XORs, and bit-rotations. Unrolling this combinatorially completely destroyed my 6.4ns timing budget. Trying to pipeline it required 10+ clock cycles, which would desynchronize the datapath and require massive AXI-Stream packet buffering that I don't have BRAM for.
- **Learn:** Software cryptographic hashes are not designed for single-cycle FPGA line-rate lookups.
- **Decide:** I pivoted to a Parameterized Galois LFSR/Toeplitz-style hash. By using an AXI-configurable 128-bit secret key and XORing it directly against the extracted packet tuple before folding, I achieved cryptographic uncertainty (an external attacker doesn't know the key) while maintaining a strict 1-cycle combinatorial latency.

### Try & Fail #2: BRAM for SNN Weights
- **Try:** To make the AI weights dynamic, I naturally attempted to store the 16 synaptic weights inside a standard True Dual-Port Block RAM (BRAM), accessible via AXI4-Lite.
- **Fail:** I completely forgot how the Spiking Neural Network (SNN) evaluates. The fully-connected layer requires a massive parallel Multiply-Accumulate (MAC). It needs to read *all 16 weights* simultaneously in exactly one clock cycle. A True Dual-Port BRAM can only output 2 values per cycle. To use BRAM, I would have to either stall the datapath for 8 cycles (ruining my line rate throughput) or spin up 8 separate BRAM tiles (a huge waste of silicon just to store 16 values).
- **Learn:** BRAM is structurally wrong for shallow, massively parallel neural network layers on an FPGA. Memory bandwidth is the ultimate bottleneck.
- **Decide:** I moved the weights into a Register File (Distributed RAM / Flops). 16 weights of 16-bits each is only 256 bits total. Storing this in standard Flip-Flops is practically free on the Artix-7 fabric and provides instantaneous parallel read access to all 16 weights simultaneously!

### The Solution (v013)
- Created an AXI4-Lite Control Plane wrapper (`ha_tff_axi_lite_regs.v`) that memory-maps the SNN weights and the Hash `secret_key`.
- Implemented the parameterized hash in `ha_tff_hash_v002.v`.
- Flattened the weight arrays in `snn_tff_layer_v005.v` to accept dynamic inputs directly from the Register File.
- Stitched it all together in `ha_tff_system_top_v005.v`.

The HA-TFF is now a true Dynamic ML Coprocessor and is robust against algorithmic collision attacks!
