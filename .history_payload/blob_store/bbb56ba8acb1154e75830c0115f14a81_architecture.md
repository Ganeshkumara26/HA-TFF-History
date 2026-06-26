# Architecture Note: v002 64-bit Parser

## Architecture Sketch
The parser module now interfaces with a 64-bit AXI4-Stream bus.

```
[10GbE MAC] ---> (s_axis_tdata 64-bit @ 156.25 MHz) ---> [ Word-Aligned FSM ]
                                                                |
                                                                +---> 5-Tuple Registers (104-bit)
```

## Latency Analysis & Mathematical Model
The data bus is 64 bits (8 bytes) wide.
The FSM now counts words (`word_cnt`).

### 64-bit Word Alignment Mapping:
Assuming MSB-first network byte order mapping where `s_axis_tdata[63:56]` is byte 0:

- **Word 0 (Bytes 0-7):** Dest MAC (6B), Src MAC (2B). (Ignored)
- **Word 1 (Bytes 8-15):** 
  - `[63:48]` = SrcMAC[4:5]
  - `[47:32]` = EtherType -> Extract to `ethertype`
  - `[31:24]` = Ver/IHL
  - `[23:16]` = TOS
- **Word 2 (Bytes 16-23):** 
  - `[7:0]` = Protocol -> Extract to `protocol`
- **Word 3 (Bytes 24-31):** 
  - `[47:16]` = Src IP -> Extract `src_ip`
  - `[15:0]` = Dst IP [31:16] -> Extract upper half of `dst_ip`
- **Word 4 (Bytes 32-39):** 
  - `[63:48]` = Dst IP [15:0] -> Extract lower half of `dst_ip`
  - `[47:32]` = Src Port -> Extract `src_port`
  - `[31:16]` = Dst Port -> Extract `dst_port`

Total Latency: Metadata is valid on **Cycle 5** (Word 4).

## Expected Timing
Logic depth increases slightly due to extracting 3 fields simultaneously in Word 4, but remains minimal (routing from registers to output pins). We expect WNS to easily pass 6.4ns constraint.
