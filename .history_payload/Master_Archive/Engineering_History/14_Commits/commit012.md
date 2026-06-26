# Commit {012}

**Message:** 2-Stage SNN Pipelining and Final Timing Closure
**Files Changed:** snn_tff_neuron_v004.v, ha_tff_system_top_v004.v

## Reason
Adder chain in the LIF neuron was the true critical path. Broke it across two cycles. Delayed Datapath to match 6-cycle latency.

## Bug Addressed
None

## Evidence Link
TIM-012 (WNS +0.517ns)

## Next Work
Prepare final report.
