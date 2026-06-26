# Commit {011}

**Message:** Add AXI-Stream Delay Line for Pipeline Alignment
**Files Changed:** axi_stream_delay_line.v, ha_tff_system_top_v003.v

## Reason
Payload was leaking past the firewall decision point. Shift register buffers it.

## Bug Addressed
BUG-006 (SNN Critical Path)

## Evidence Link
TIM-011 (WNS -0.400ns)

## Next Work
Pipeline the SNN.
