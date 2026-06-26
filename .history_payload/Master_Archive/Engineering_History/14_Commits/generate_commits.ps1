$commits = @(
    @{
        id = "001"; msg = "Initial 8-bit parser"; files = "ha_tff_parser_v001.v, tb_ha_tff_parser_v001.v"; reason = "Start of project, naive byte-by-byte approach."; bug = "None"; ev = "SIM-001"; next = "Realized it requires 1.25GHz clock. Need 64-bit."
    },
    @{
        id = "002"; msg = "Pivot to 64-bit word-aligned parser"; files = "ha_tff_parser_v002.v"; reason = "Physics First constraint. Must lower clock to 156.25 MHz."; bug = "None"; ev = "ARCH-v002"; next = "Need hash function."
    },
    @{
        id = "003"; msg = "Add Combinatorial XOR Cuckoo Hash"; files = "ha_tff_hash_v001.v"; reason = "Need 4 parallel hash functions for BRAM lookups. CRC takes too many LUTs."; bug = "None"; ev = "ADR-003"; next = "Need BRAM banks."
    },
    @{
        id = "004"; msg = "Instantiate True Dual-Port BRAM Banks"; files = "ha_tff_bram_bank.v, ha_tff_datapath_top.v"; reason = "TCAM is too expensive. Inferring RAMB36E1."; bug = "None"; ev = "SYNTH-004"; next = "Need to match outputs."
    },
    @{
        id = "005"; msg = "Pipeline the Cuckoo Matcher"; files = "ha_tff_matcher_v002.v, ha_tff_datapath_top_v002.v"; reason = "Wide 104-bit combinatorial equality comparisons destroy timing. Must register outputs."; bug = "Combinatorial Matcher (abandoned)"; ev = "SIM-005"; next = "Static rules are too rigid."
    },
    @{
        id = "006"; msg = "Research Pivot: Spiking Neural Networks"; files = "None"; reason = "Zero-day threats bypass static rules. Must implement behavioral AI without using DSP slices."; bug = "None"; ev = "ARCH-v006"; next = "Write SNN RTL."
    },
    @{
        id = "007"; msg = "Implement baseline LIF Neuron and SNN Layer"; files = "snn_tff_neuron_v001.v, snn_tff_layer_v001.v"; reason = "Map mathematical Euler approximation to hardware."; bug = "None"; ev = "None"; next = "Verify Signed Math."
    },
    @{
        id = "008"; msg = "Fix SNN Signed Arithmetic and Leak Logic"; files = "snn_tff_neuron_v003.v, snn_tff_layer_v003.v"; reason = "Unsigned threshold parameters caused negative potentials to trigger massive spike avalanches."; bug = "BUG-003, BUG-004"; ev = "SIM-008"; next = "Need Feature Encoder."
    },
    @{
        id = "009"; msg = "Implement Static Feature Encoder"; files = "snn_feature_encoder.v"; reason = "SNN needs binary spikes. Datapath provides 104-bit tuples. Hardcoded heuristics to bridge the gap."; bug = "None"; ev = "ADR-009"; next = "Top-level integration."
    },
    @{
        id = "010"; msg = "Integrate System Top (Failed Timing)"; files = "ha_tff_system_top_v002.v, tb_ha_tff_system_top_v002.v"; reason = "Merged Datapath and SNN using a combinatorial AND gate."; bug = "BUG-005 (DCE)"; ev = "TIM-010 (WNS -0.465ns)"; next = "Fix timing."
    },
    @{
        id = "011"; msg = "Add AXI-Stream Delay Line for Pipeline Alignment"; files = "axi_stream_delay_line.v, ha_tff_system_top_v003.v"; reason = "Payload was leaking past the firewall decision point. Shift register buffers it."; bug = "BUG-006 (SNN Critical Path)"; ev = "TIM-011 (WNS -0.400ns)"; next = "Pipeline the SNN."
    },
    @{
        id = "012"; msg = "2-Stage SNN Pipelining and Final Timing Closure"; files = "snn_tff_neuron_v004.v, ha_tff_system_top_v004.v"; reason = "Adder chain in the LIF neuron was the true critical path. Broke it across two cycles. Delayed Datapath to match 6-cycle latency."; bug = "None"; ev = "TIM-012 (WNS +0.517ns)"; next = "Prepare final report."
    }
)

foreach ($c in $commits) {
    $content = @"
# Commit {$($c.id)}

**Message:** $($c.msg)
**Files Changed:** $($c.files)

## Reason
$($c.reason)

## Bug Addressed
$($c.bug)

## Evidence Link
$($c.ev)

## Next Work
$($c.next)
"@
    Set-Content -Path "d:\Downloads\ha_tff\Engineering_History\14_Commits\commit$($c.id).md" -Value $content
}
