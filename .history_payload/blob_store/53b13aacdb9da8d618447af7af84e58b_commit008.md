# Commit {008}

**Message:** Fix SNN Signed Arithmetic and Leak Logic
**Files Changed:** snn_tff_neuron_v003.v, snn_tff_layer_v003.v

## Reason
Unsigned threshold parameters caused negative potentials to trigger massive spike avalanches.

## Bug Addressed
BUG-003, BUG-004

## Evidence Link
SIM-008

## Next Work
Need Feature Encoder.
