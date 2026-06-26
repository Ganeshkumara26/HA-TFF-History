# Architecture Note: v007 Fully Connected SNN Layer

## Architecture Sketch

```
[ 8-bit Spike Vector ]
       |
       +--------> (Synaptic Weights W0) ----> [ Neuron 0: Safe ]
       |
       +--------> (Synaptic Weights W1) ----> [ Neuron 1: Anomaly ]
```

## Latency Analysis & Mathematical Model
The inputs arrive as an 8-bit bus, where each bit is a spike (`1` or `0`).

For Neuron 0:
`Current_0 = sum( Spike[i] * W0[i] ) for i in 0..7`
Since `Spike[i]` is binary, this simplifies to:
`if (Spike[i]) Current_0 += W0[i];`

**Combinational Summation:**
We will use an `always @(*)` block to sum the weights combinatorially. 
8 inputs mean a tree of 7 adders.
In Artix-7, `CARRY4` primitives chain adders efficiently. 7 chained additions might create a long critical path, so we will register the result (`current_reg`) before passing it into the `snn_tff_neuron`.

**Total SNN Layer Latency:**
- Cycle 1: Combinatorial sum + register.
- Cycle 2: Neuron Leak/Integrate/Fire logic.
- Total = 2 cycles.
