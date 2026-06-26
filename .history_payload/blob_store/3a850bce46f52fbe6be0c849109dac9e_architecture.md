# Architecture Note: v009 Feature Encoder Latency

## Architecture Sketch

```
[ Parser 104-bit Tuple ]
           |
           v
  [ Feature Encoder ]
           |
   (8-bit Spike Vector)
```

## Latency Analysis & Mathematical Model
The extraction logic uses standard 16-bit and 32-bit equality comparators.
- `Spike 0: (protocol == 8'd6)` -> 8-bit comparator -> 1 LUT.
- `Spike 3: (src_port > 16'd40000)` -> 16-bit magnitude comparator -> ~3 LUTs (Carry chain).
- `Spike 5: (src_ip[31:8] == 24'hC0A864)` -> 24-bit comparator -> ~4 LUTs.

All of these resolve in a single clock cycle.
Therefore, the Feature Encoder adds **1 cycle** of latency to the SNN coprocessor path.

### Cumulative SNN Path Latency (So far):
- Parser: Valid at T0
- Encoder: Valid at T1
- Layer Sum: Valid at T2
- Neuron LIF: Valid at T3

The SNN will output its anomaly decision 3 cycles after the Parser.
