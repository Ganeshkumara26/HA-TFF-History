# Engineering Debt v010

## Timing Debt
- WNS is -0.465ns. The top-level Combinatorial AND gate is destroying the critical path.

## Verification Debt
- Finally wrote 	b_ha_tff_system_top_v002.v. Coverage is still poor.

## Pipeline Alignment Debt
- Massive bug discovered: Payload flows out 4 cycles before firewall decision is made!

## Known Hacks
- SNN Weights are still hardcoded wires.
