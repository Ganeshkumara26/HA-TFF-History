# Architecture Note: v012 Final Pipeline Alignment Model

## Architecture Sketch

```
[ s_axis_tdata ]
      |
      v
[ Delay Line (6 Cycles) ] ---------> (m_axis_tdata)
      |
[ Parser (extracts at T=5) ]
      |
      +---> [ Datapath (4 Cycles) ] ---> [ 1-Cycle Delay ] ---+
      |                                                       |
      +---> [ Encoder (1 Cycle) ]                             v
      |                                                     [ AND ] ---> (m_axis_tvalid)
      +---> [ SNN Layer (2 Cycles) ]                          ^
      |                                                       |
      +---> [ SNN Neuron (2 Cycles) ] ------------------------+
```

## Latency Analysis & Mathematical Model
Let `T=0` be the arrival of Word 0.
- `T=4`: Parser asserts `tuple_valid` (Word 4).
- `T=5`: Hash computed / Feature Encoded.
- `T=6`: BRAM read / SNN Layer Sum registered.
- `T=7`: Matcher Registered / SNN Neuron Stage 1 (u_temp) registered.
- `T=8`: Datapath `dp_action_forward` valid / SNN Neuron Stage 2 (anomaly_detected) valid.
- `T=9`: Top-level AND gate output is registered and driven to `m_axis_tvalid`.

**Total Pipeline Depth:** The payload must be delayed by exactly 6 cycles (Word 4 arrival + 5 subsequent processing cycles).

## Expected Timing
By splitting the neuron addition and the comparison into two cycles, the deepest logic path is now just a 16-bit adder. `TIM-012` confirms Positive Slack (`WNS = +0.517ns`). Timing is closed.
