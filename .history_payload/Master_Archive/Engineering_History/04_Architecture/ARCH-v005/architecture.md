# Architecture Note: v005 Datapath Latency Model

## Architecture Sketch

```
[ s_axis_tdata ]
      |
      v
  [ Parser ]  ---- (104-bit tuple) --------+
      | (Word 4)                           |
      v                                    v
   [ Hash ]                             [ Delay ]
      | (hash0..3)                         |
      v                                    v
 [ 4x BRAMs ]                              |
      | (candidate0..3)                    |
      +------------------------------------+
      v
 [ Matcher ]
      |
      v
[ Action Output ]
```

## Latency Analysis & Mathematical Model
Let `T0` be the cycle when the 5-tuple becomes valid (Word 4 of the Ethernet frame).
- `T0`: Parser asserts `tuple_valid`.
- `T1`: Hash module computes `hash_0`...`hash_3` and asserts `valid_out`.
- `T2`: BRAM banks receive addresses.
- `T3`: BRAM banks output read data.
- `T4`: Matcher registers the comparison output (due to `v002` pipelining).

**Total Decision Latency:** 4 clock cycles from the moment the packet header is fully parsed.
At 156.25 MHz (6.4ns), the firewall decision takes exactly `4 * 6.4 = 25.6 ns`.

This is incredibly fast compared to a Linux CPU kernel (iptables/nftables) which typically requires ~10-50 microseconds (10,000+ ns) to process a packet.
