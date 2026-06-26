# Architecture Note: v006 LIF Neuron Mathematical Model

## Architecture Sketch

```
[ Binary Spikes I(t) ] ---> ( Add Synaptic Weights W ) ---> [ Membrane Potential U(t) ]
                                                                   |
                                                                   v
                                                        [ Compare U(t) > Threshold ]
                                                                   |
                                                         (Spike Output) + (Reset U)
```

## Mathematical Model: Leaky Integrate-and-Fire (LIF)

The standard continuous LIF equation is:
`dU/dt = -(U - U_rest)/tau + I(t)`

For FPGA implementation at 156.25 MHz, we discretize this using Euler's method and map it to fixed-point integer arithmetic.

**Hardware Equation:**
`U[t] = U[t-1] - (U[t-1] >>> LEAK_SHIFT) + (Spike_in ? Weight : 0)`

If `U[t] >= THRESHOLD`, emit spike and reset `U[t] = 0`.

### Physical Mapping Analysis:
- `U[t-1] >>> LEAK_SHIFT`: This is a bitwise arithmetic right-shift. It costs 0 LUTs in hardware (it's just wire routing).
- `(Spike_in ? Weight : 0)`: This is a 2-to-1 Multiplexer.
- Addition/Subtraction: Standard 16-bit Adder/Subtractor (requires Carry Chains - `CARRY4` primitives).

By restricting the leak parameter to a power of 2 (`LEAK_SHIFT`), we entirely avoid DSP slices. 

## Expected Timing
The calculation requires a Subtract, an Add, and a Compare in a single clock cycle. This might be slightly deep for 6.4ns, but we will prototype it first and verify timing later.
