# Ethernet, IPv4, and UDP: A Hardware Perspective

## The Goal
Before I can write a Verilog parser, I need to understand exactly what a packet looks like on the wire.

## Ethernet Frame
- The lowest level (Layer 2).
- Starts with a 7-byte Preamble and 1-byte SFD (Start of Frame Delimiter). *Note: The MAC/PHY strips this, so the FPGA will never see it. The AXI-Stream will start directly at the Destination MAC.*
- **Header:** 14 bytes.
  - Bytes 0-5: Dst MAC
  - Bytes 6-11: Src MAC
  - Bytes 12-13: EtherType (0x0800 for IPv4).

## IPv4 Header
- Follows immediately after Ethernet (Layer 3).
- **Header:** 20 bytes (usually, assuming no options).
- **Key Fields:**
  - Byte 9 (from IP start): Protocol (17 = UDP, 6 = TCP).
  - Bytes 12-15: Source IP
  - Bytes 16-19: Destination IP
- *Math for Verilog:* Since Ethernet is 14 bytes, the Source IP starts at Byte 26 of the whole packet. (14 + 12).

## UDP Header
- Layer 4. Extremely simple. Stateless.
- **Header:** 8 bytes.
  - Bytes 0-1: Source Port
  - Bytes 2-3: Dest Port
  - Bytes 4-5: Length
  - Bytes 6-7: Checksum

## The Parsing Hypothesis
If my AXI-Stream bus is 64 bits wide (8 bytes per clock cycle):
- **Clock 0:** Bytes 0-7 (Dst MAC, part of Src MAC)
- **Clock 1:** Bytes 8-15 (Src MAC, EtherType, IP Version/IHL)
- **Clock 2:** Bytes 16-23 (IP Type of Service, Total Length, ID, Flags)
- **Clock 3:** Bytes 24-31 (TTL, Protocol, Header Checksum, Source IP)
  - *Wait!* Source IP is bytes 26-29. This straddles Clock 3.
- **Clock 4:** Bytes 32-39 (Dest IP, UDP Src Port, UDP Dst Port).
  - Dest IP is bytes 30-33. Straddles Clock 3 and 4!

**Holy crap.** The fields cross the 64-bit boundaries. Writing a parser is not going to be a simple `if (cycle == X)`. I will need a shift register to align the bytes across clock cycles. This is much harder than I thought.
