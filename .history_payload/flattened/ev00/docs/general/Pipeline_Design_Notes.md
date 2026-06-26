# Pipeline Design & Timing Closure

## The Physics of Silicon
A clock frequency of 156.25 MHz means the period is 6.4 nanoseconds.
If I build a massive combinatorial logic block (e.g., 4 hash functions + 4 BRAM lookups + a 104-bit equality check), the electrons literally cannot travel through the silicon gates in under 6.4ns.
Vivado will fail synthesis with "Negative Slack".

## The Solution: Pipelining
Instead of doing everything in 1 clock cycle, I break it up using registers (Flip-Flops).

- **Cycle 1:** Calculate Hashes. Save to Register A.
- **Cycle 2:** Query BRAM using Register A. Save BRAM output to Register B.
- **Cycle 3:** Compare incoming tuple with Register B. Save Match Result to Register C.
- **Cycle 4:** Apply Firewall Drop logic using Register C.

**Trade-off:** It now takes 4 clock cycles (Latency = 25.6ns) to make a decision. But the system can accept a NEW packet every single clock cycle (Throughput = 156.25M ops/sec).

## The Delay Line Issue
If the decision takes 4 clock cycles, but the packet data is streaming through the firewall right now, the firewall will drop the *wrong* part of the packet.
I must delay the `tdata` stream by exactly 4 clock cycles to match the pipeline latency. I will use AXI-Stream FIFOs or Shift Register LUTs (SRL16) to build a delay line.
