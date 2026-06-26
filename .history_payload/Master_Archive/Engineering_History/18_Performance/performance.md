# Performance Evolution Tracker

## Latency
- Initial Datapath: 4 cycles
- Final Hybrid System: 6 cycles

## Area
- BRAMs: Stabilized at 12 BRAM36E1 (due to Cuckoo Hash matrix sizing).
- LUTs: Increased from 240 (pure datapath) to 495 (hybrid SNN), but still < 1% of Artix-7 capacity.
- DSPs: Maintained at exactly 0.

## Frequency
- v001 Attempt: Required 1.25GHz (Physically Impossible).
- v002-v012: Stabilized at 156.25 MHz (Target for 10GbE 64-bit).
- Timing Closure: Finally achieved in v012 (+0.517ns WNS) by adding a 2-stage pipeline to the SNN membrane adders.
