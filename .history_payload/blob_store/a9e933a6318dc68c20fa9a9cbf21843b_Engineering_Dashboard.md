# Engineering Dashboard (Resource & Timing Evolution)

This dashboard tracks the utilization and physical metrics of the Artix-7 100T target fabric across iterations.

| Iteration | Module Synthesized | LUTs | FFs | BRAM | DSP | Power (W) | Latency | WNS (ns) | Status |
|-----------|--------------------|------|-----|------|-----|-----------|---------|----------|--------|
| **v001** | `ha_tff_parser_v001` | 45 | 110 | 0 | 0 | < 0.1 | 5 cycles | +4.100 | Abandoned (8-bit) |
| **v002** | `ha_tff_parser_v002` | 130 | 114 | 0 | 0 | < 0.1 | 5 cycles | +3.850 | Verified |
| **v003** | `ha_tff_hash_v001` | 48 | 48 | 0 | 0 | < 0.1 | 1 cycle | +3.200 | Verified |
| **v004** | `ha_tff_datapath_top`| 240 | 185 | 12 | 0 | 0.15 | 4 cycles | +1.800 | Verified |
| **v005** | `ha_tff_datapath_v002`| 285 | 290 | 12 | 0 | 0.17 | 4 cycles | +1.200 | Pipelined |
| **v006** | `snn_tff_neuron` | 32 | 16 | 0 | 0 | < 0.1 | 1 cycle | N/A | Math Model |
| **v007** | `snn_tff_layer` | 115 | 32 | 0 | 0 | < 0.1 | 2 cycles | -0.100 | Buggy |
| **v008** | `snn_tff_layer_v003` | 128 | 32 | 0 | 0 | < 0.1 | 2 cycles | +0.050 | Fixed Math |
| **v009** | `snn_feature_encoder`| 18 | 8 | 0 | 0 | < 0.1 | 1 cycle | +4.500 | Verified |
| **v010** | `ha_tff_system_top` | 445 | 340 | 12 | 0 | 0.28 | 4 cycles | **-0.465** | **FAILED TIMING** |
| **v011** | `ha_tff_system_top` | 460 | 365 | 12 | 0 | 0.29 | 4 cycles | **-0.400** | **FAILED TIMING** |
| **v012** | `ha_tff_system_top` | 495 | 430 | 12 | 0 | 0.31 | 6 cycles | **+0.517** | **CLOSED** |

## Notes on Performance Metrics
- **Clock Target:** 156.25 MHz (6.400 ns period) to sustain 10Gbps on a 64-bit bus.
- **BRAM Utilization:** 12 `RAMB36E1` primitives consumed by the Cuckoo Hash tables (4 banks * 3 BRAMs).
- **DSP Utilization:** 0. By choosing an SNN (Leaky Integrate-and-Fire) and restricting leak division to Arithmetic Right Shifts (`>>>`), we completely eliminated the need for hardware multipliers.
- **Power:** Dynamic power remained incredibly low (< 0.5W) due to the absence of active DSP chains and TCAM.
