# Commit {005}

**Message:** Pipeline the Cuckoo Matcher
**Files Changed:** ha_tff_matcher_v002.v, ha_tff_datapath_top_v002.v

## Reason
Wide 104-bit combinatorial equality comparisons destroy timing. Must register outputs.

## Bug Addressed
Combinatorial Matcher (abandoned)

## Evidence Link
SIM-005

## Next Work
Static rules are too rigid.
