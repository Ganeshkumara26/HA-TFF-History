# BUG-005: Vivado Dead Code Elimination

**Date:** Week 10 (v010)
**Status:** Resolved

## Symptom
During synthesis (`SYNTH-010`) of `ha_tff_system_top_v001`, the utilization report showed 0 BRAMs and only 40 LUTs. The entire Cuckoo Hash Datapath disappeared from the netlist.

## Root Cause
In my early testbench (`tb_v010`), I was forcing the inputs to the SNN Feature Encoder to verify the anomaly detection, but I left `s_axis_tdata` tied to `0`. 
Vivado Synthesis detected that the Datapath inputs never toggled. It performed constant propagation, determined the Cuckoo Matcher output would always be `0`, and deleted the BRAMs, the Hasher, and the Parser via Dead Code Elimination (DCE).

## Resolution
Updated `tb_ha_tff_system_top_v002.v` to inject realistic 64-bit Ethernet frames spanning 6 cycles, driving all datapath inputs. Re-ran synthesis. The logic is now preserved (193 LUTs, 23 BRAMs).
