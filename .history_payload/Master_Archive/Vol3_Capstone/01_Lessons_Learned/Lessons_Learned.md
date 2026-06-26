# Architectural Limitations & Lessons Learned

## Timing Closures vs Theoretical Math
- **Lesson:** Mathematical algorithms are useless if they cannot physically route on the fabric. 
- **Example:** I initially designed the SNN to use standard integer division for the membrane leak. Vivado attempted to infer a massive divider that failed timing immediately. By shifting to an Arithmetic Right Shift (>>>), I dropped the clock cycle requirement to 1 cycle. Physics constraints must dictate algorithmic choices.

## The Cost of Determinism
- **Lesson:** Pipelining guarantees frequency but punishes latency.
- **Example:** To close timing, I had to pipeline the Cuckoo Matcher and the SNN adders. The system decision latency crept from 4 cycles to 6 cycles. The cost of running at 156.25 MHz is deeper pipelines.
