# Architecture Note: v010 System Timing Failure

## Architecture Sketch

```
[ Datapath (4 Cycles) ] ---> (dp_action_forward) --+
                                                   |
                                                   v
                                                 [ AND ] ---> (final_forward)
                                                   ^
                                                   |
[ SNN Coprocessor (3 Cycles) ] -> (anomaly_detected)-+
```

## Mathematical Model: Timing Path
The Critical Path traces from the start of the current cycle registers, through the logic, to the destination register.
`Delay = T_clk_to_Q + T_logic + T_routing + T_setup`
Constraint: `Delay <= 6.400 ns`

According to `TIM-010`:
The delay through the SNN Threshold comparator + the top-level AND gate exceeded 6.865 ns.
`WNS = 6.400 - 6.865 = -0.465 ns`.

## Physical Analysis
The combinatorial merge (`ADR-010`) bridges two distant physical regions on the FPGA fabric (the BRAMs and the SNN Adders). The `T_routing` penalty alone destroyed the timing margin. We must pipeline the `final_forward` signal.
