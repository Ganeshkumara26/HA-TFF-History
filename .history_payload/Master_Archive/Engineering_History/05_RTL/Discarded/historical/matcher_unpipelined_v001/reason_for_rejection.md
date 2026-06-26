# Reason for Rejection: Combinatorial Matcher (v001)

## Context
During Week 5, while integrating the Datapath Top, I began writing `matcher_unpipelined_v001`. The goal was to take the four 105-bit outputs from the BRAM banks and combinatorially compare them against the 104-bit parsed tuple.

## Why it was abandoned (Physics First)
A 104-bit equality comparison (`==`) requires a wide AND-tree. 
In a LUT6 architecture:
- 104 bits -> 52 LUTs (Level 1)
- 52 bits -> 26 LUTs (Level 2)
- 26 bits -> 13 LUTs (Level 3)
- ... and so on.
This creates a logic depth of at least 4-5 levels *just* for the equality check.

Once we have the 4 equality results (`match_0`, `match_1`, etc.), we must multiplex the `action_flag` out of the winning BRAM bank. This adds another 1-2 levels of logic.

Finally, we must route the signals from 4 physically distributed BRAM banks across the FPGA fabric to a central matcher. The routing delay alone could easily consume 2-3 ns.

Combined with the logic depth, this approach would almost certainly fail the 6.4ns timing constraint for 156.25 MHz. 

## Action Taken
The code was abandoned mid-write. I pivoted to `ha_tff_matcher_v002.v` which explicitly registers the output, adding 1 cycle of latency but breaking the critical path.
