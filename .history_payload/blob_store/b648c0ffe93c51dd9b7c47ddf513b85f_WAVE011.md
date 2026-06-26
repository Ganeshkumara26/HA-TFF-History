# WAVE011 Analysis: Pipeline Misalignment

## Observed Behavior
In SIM-010, the s_axis_tdata payload enters at T=0. The nomaly_detected spike goes HIGH at T=4. 
However, between T=0 and T=4, the raw s_axis_tdata has already passed through the combinatorial wires directly to the output.

## Root Cause
The Firewall decision takes 4 cycles. The payload is not buffered. 

## Action Required
Must implement a 4-cycle (later 6-cycle) AXI-Stream Shift Register to hold the payload data until the m_axis_tvalid signal is ready.
