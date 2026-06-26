# Architecture Note: v001 Parser

## Architecture Sketch
The parser module sits directly on the AXI4-Stream interface.

```
[10GbE MAC] ---> (s_axis_tdata 64-bit) ---> [ Parser FSM ]
                                                |
                                                +---> 5-Tuple Registers (104-bit)
```

## Latency Analysis & Mathematical Model
The data bus is 64 bits (8 bytes) wide.
The typical UDP/IPv4 packet header is structured as:
- Ethernet MAC (14 bytes)
- IPv4 Header (20 bytes)
- UDP Header (8 bytes)
Total Header Size = 42 bytes.

Number of cycles required to receive the header:
`Cycles = ceil(42 bytes / 8 bytes/cycle) = 6 cycles.`

### Byte Alignment Mapping:
Assuming MSB-first network byte order mapping:
- Cycle 1 (Bytes 0-7): Dest MAC, part of Src MAC
- Cycle 2 (Bytes 8-15): Remainder of Src MAC, EtherType. **If EtherType != 0x0800, drop.**
- Cycle 3 (Bytes 16-23): IPv4 Protocol (Byte 23). **Extract `protocol`.**
- Cycle 4 (Bytes 24-31): IPv4 Src IP (Bytes 26-29), part of Dst IP. **Extract `src_ip`.**
- Cycle 5 (Bytes 32-39): Remainder of Dst IP, Src Port, Dst Port. **Extract `dst_ip`, `src_port`, `dst_port`.**

## Expected Timing
Because the extraction occurs in distinct, non-overlapping cycles, logic depth should not exceed 1 or 2 levels. We expect a Worst Negative Slack (WNS) well above 0.00ns.
