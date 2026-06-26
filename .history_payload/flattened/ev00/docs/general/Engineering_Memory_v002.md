# Engineering Memory - Iteration 002 (Week 2)

## Research Direction & Goals
**Current Goal**: Re-architect the parser to use a 64-bit AXI-Stream interface to sustain 10GbE line rates.
**Previous Goal**: Build a basic 8-bit parser (failed physical constraints).

## Knowledge Boundaries
**Things I understand:**
- The math of line-rate networking: 10Gbps on an 8-bit bus requires 1.25 GHz. That is impossible on my FPGA. I must use a 64-bit bus at 156.25 MHz. (See `REQ-v002`).

**Things I believe:**
- I believe mapping the byte offsets to 64-bit word chunks is straightforward, though splitting the Destination IP across Word 3 and Word 4 is slightly annoying to write in Verilog.

**Things I do not understand:**
- How do I test this efficiently? Writing 64-bit hex streams manually in my testbench is incredibly tedious. 

## Architecture & Math
See `ARCH-v002`. We redesigned the FSM from counting 42 individual bytes to counting 5 discrete 64-bit words. The 5-tuple extraction happens in bulk assignments across Word 3 and Word 4. (See `ADR-002`).

## Evidence IDs & Cross-Referencing
- **RTL**: `05_RTL/rtl_v002/ha_tff_parser_v002.v` 
- **Requirements**: `REQ-v002`

## Emotional Engineering State
- **Parser Confidence**: 50% (The logic makes sense, but the hex slicing might have off-by-one errors. I need to simulate it).
- **Verification Confidence**: 5% (I dread writing the testbench for this).
- **Overall Architecture**: 15%.

## Alternative Solutions & Failed Branches
The entire v001 8-bit architecture is officially an abandoned branch. I've left the code in `rtl_v001/` for historical reference, but it will never be synthesized into the final datapath. It was a classic beginner mistake to ignore the clock frequency implications of a narrow bus.

## Engineering Debt Register
- **Verification Debt**: High. I need to write `tb_ha_tff_parser_v002.v` and figure out how to inject 64-bit chunks properly.
- **RTL Debt**: The parser still assumes no IPv4 options (`Q001` remains open).

## Next Objectives
- Verify `v002` logic in simulation.
- Start researching Exact Match lookup architectures so I can actually do something with the 5-tuple.
