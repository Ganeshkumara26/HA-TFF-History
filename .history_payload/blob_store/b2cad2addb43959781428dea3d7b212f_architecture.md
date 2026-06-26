# Architecture Note: v004 BRAM Banks

## Architecture Sketch

```
[ Hash Generators ] 
       | (hash_0, hash_1, hash_2, hash_3)
       v
+-------------+  +-------------+  +-------------+  +-------------+
| BRAM Bank 0 |  | BRAM Bank 1 |  | BRAM Bank 2 |  | BRAM Bank 3 |
| (4096 x 105)|  | (4096 x 105)|  | (4096 x 105)|  | (4096 x 105)|
+-------------+  +-------------+  +-------------+  +-------------+
       |                |                |                |
       v                v                v                v
  [ Read 0 ]       [ Read 1 ]       [ Read 2 ]       [ Read 3 ]
```

## Latency Analysis & Mathematical Model
- Address computation (Hashing): 1 cycle.
- BRAM Read: 1 cycle (synchronous).
- **Total Latency to get Candidate Rules:** 2 cycles.

The data width is 105 bits (104-bit tuple + 1-bit action). 
Vivado will infer three 36Kb BRAMs (`RAMB36E1`) per bank to span the 105-bit width.
Total BRAM usage = 3 * 4 = 12 BRAMs.
Artix-7 100T has 135 BRAMs. We are using < 10% of memory capacity. This is an excellent architectural fit.
