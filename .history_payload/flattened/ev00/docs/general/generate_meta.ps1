# Engineering Debt
$debt_v001 = @"
# Engineering Debt v001

## Verification Debt
- Absolutely none. Did not write a single testbench.

## Timing Debt
- Used 8-bit bus. Requires 1.25GHz clock. Impossible.

## Known Hacks
- Hardcoded Ethernet payload hex string into testbench just to see if it parses.
"@
Set-Content -Path "d:\Downloads\ha_tff\Engineering_History\15_Engineering_Debt\Debt_v001.md" -Value $debt_v001

$debt_v010 = @"
# Engineering Debt v010

## Timing Debt
- WNS is -0.465ns. The top-level Combinatorial AND gate is destroying the critical path.

## Verification Debt
- Finally wrote `tb_ha_tff_system_top_v002.v`. Coverage is still poor.

## Pipeline Alignment Debt
- Massive bug discovered: Payload flows out 4 cycles before firewall decision is made!

## Known Hacks
- SNN Weights are still hardcoded wires.
"@
Set-Content -Path "d:\Downloads\ha_tff\Engineering_History\15_Engineering_Debt\Debt_v010.md" -Value $debt_v010

# TODOs
$todo_v005 = @"
# TODO v005

## DONE
- Cuckoo Hash Table Banks
- Parser Datapath Integration

## IN PROGRESS
- Matcher module (Pipelined version)

## BLOCKED
- Cannot test full datapath until Matcher is finished.

## NEXT WEEK
- Start researching Anomaly Detection (SNNs).
"@
Set-Content -Path "d:\Downloads\ha_tff\Engineering_History\19_TODO\todo_v005.md" -Value $todo_v005

# Waveform Analysis
$wave001 = @"
# WAVE011 Analysis: Pipeline Misalignment

## Observed Behavior
In `SIM-010`, the `s_axis_tdata` payload enters at `T=0`. The `anomaly_detected` spike goes HIGH at `T=4`. 
However, between `T=0` and `T=4`, the raw `s_axis_tdata` has already passed through the combinatorial wires directly to the output.

## Root Cause
The Firewall decision takes 4 cycles. The payload is not buffered. 

## Action Required
Must implement a 4-cycle (later 6-cycle) AXI-Stream Shift Register to hold the payload data until the `m_axis_tvalid` signal is ready.
"@
Set-Content -Path "d:\Downloads\ha_tff\Engineering_History\11_Verification\Waveform_Analysis\WAVE011.md" -Value $wave001

# Verification Coverage
$cov_v012 = @"
# Verification Coverage Report v012

## Verified Successfully
- [x] Normal valid TCP packet
- [x] Normal valid UDP packet
- [x] Threat matched in Cuckoo Hash (Drop triggered)
- [x] Threat matched by SNN Anomaly (Drop triggered)
- [x] Endian-byte swapping on 64-bit boundaries

## Unverified / Ignored
- [ ] IPv4 packets with IP Options (IHL > 5).
- [ ] Fragmented IP packets.
- [ ] IPv6.
- [ ] VLAN Tagged (802.1Q) frames.
- [ ] ICMP packets.
"@
Set-Content -Path "d:\Downloads\ha_tff\Engineering_History\11_Verification\Coverage_Report_v012.md" -Value $cov_v012
