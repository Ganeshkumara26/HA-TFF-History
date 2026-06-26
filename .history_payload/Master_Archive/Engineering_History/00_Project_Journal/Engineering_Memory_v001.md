# Engineering Memory - Iteration 001 (Week 1)

## Research Direction & Goals
**Current Goal**: Develop an AXI4-Stream parser to extract 5-tuple telemetry metadata from a 10GbE line. 
**Reasoning**: Software kernels cannot sustain line-rate packet parsing. I need a hardware accelerator. (See `REQ-v001`).

## Knowledge Boundaries
**Things I understand:**
- Ethernet frames arrive 64-bits at a time (8 bytes) at 156.25 MHz.
- The 5-tuple consists of Source IP, Dest IP, Source Port, Dest Port, and Protocol.

**Things I suspect / assume:**
- I assume it's fine to just write a fixed-cycle State Machine and ignore variable-length IPv4 "Options". (See `Assumption A-001`).

**Things I do not understand:**
- How much routing delay this will introduce in the Artix-7 fabric.
- What to actually do with the 5-tuple once I have extracted it.

## Architecture & Math
See `ARCH-v001`. The mathematical model predicts exactly 5 clock cycles to extract the relevant byte offsets. We explicitly rejected buffering the entire packet to save LUTs and avoid combinational delay. (See `ADR-001`).

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v001/ha_tff_parser_v001.v` 
- **Simulation**: `SIM-001` supports that the parser correctly extracts `0x0A000001` from the dummy hex stream at exactly cycle 5.
- **Synthesis**: `SYNTH-001` (156.25 MHz constraint) passed easily. The FSM only uses a handful of registers.

## Emotional Engineering State
- **Parser Confidence**: 80% (It simulates, but I'm worried about edge cases).
- **Timing Confidence**: 95% (FSM is very lightweight).
- **Overall Architecture**: 10% (I have no idea how I'll store or look up these IPs yet).

## Alternative Solutions & Failed Branches
I originally considered a massive 336-bit shift register to slice the entire header combinatorially, but rejected it because the fanout would destroy the 6.4ns timing constraint. 

## Next Objectives
- I need to figure out how to match these 5-tuples against a list of "known" IP addresses. I will investigate Hash Tables next week.
