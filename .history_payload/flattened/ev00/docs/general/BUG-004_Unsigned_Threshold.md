# BUG-004: Unsigned Parameter Casting Trap

**Date:** Week 8 (v008)
**Status:** Resolved

## Symptom
In `v002`, when a neuron received inhibitory (negative) spikes, its membrane potential would drop below zero (e.g., `-10`). Immediately, the neuron would emit a spike!

## Root Cause
The `THRESHOLD` parameter was declared as `parameter THRESHOLD = 1000`. In Verilog, this defaults to an unsigned 32-bit integer. 
The comparison `if (u_temp >= THRESHOLD)` forced `u_temp` (which is a signed 16-bit register) to be cast to unsigned.
`-10` cast to unsigned 16-bit is `65526`. 
Since `65526 >= 1000`, the neuron fired.

## Resolution
Explicitly cast the parameter: `parameter signed [15:0] THRESHOLD = 16'sd1000`. `v003` RTL fixed this.
