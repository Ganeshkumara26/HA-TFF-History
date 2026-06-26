# Engineering Question Register

This register tracks the evolution of my technical curiosity. Every hardware feature I eventually built began as a question asked during my software internship or foundation studies.

---

### Question 001
**Question:** Can an FPGA parse Ethernet frames faster than a Node.js software stack?
**Status:** Resolved
**Evidence:** Code reading of `MavlinkBridge.js` revealed garbage-collection pauses during `JSON.parse`.
**Investigation:** Studied AXI Stream and hardware state machines (Vol0).
**Resolution:** Designed the `ha_tff_parser` (Vol2).
**Affected Architecture:** HA-TFF Datapath.

---

### Question 002
**Question:** How do you perform exact-match lookups in hardware without a massive CAM (Content Addressable Memory)?
**Status:** Resolved
**Evidence:** TCAM is too expensive and power-hungry for an Artix-7.
**Investigation:** Researched Hash Tables and collision resolution in silicon.
**Resolution:** Implemented 4-way Cuckoo Hashing using XOR folding and BRAM primitives (Vol2/v004).
**Affected Architecture:** Cuckoo Matcher Module.

---

### Question 003
**Question:** Can wide combinatorial logic (like a 104-bit equality check) complete in a single clock cycle at 156.25 MHz?
**Status:** Resolved (Negative)
**Evidence:** Synthesis crashed; routing delay destroyed timing margins.
**Investigation:** Learned the absolute necessity of Pipeline Design (Vol0).
**Resolution:** Pipelined the Cuckoo Matcher across multiple clock cycles (Vol2/v005).
**Affected Architecture:** Entire Firewall Datapath.

---

### Question 004
**Question:** Static firewall rules are easily evaded. Can we detect malicious telemetry using behavioral AI on an FPGA?
**Status:** Resolved
**Evidence:** MLPs require massive matrix multiplications (DSPs). Artix-7 lacks DSP density.
**Investigation:** Researched Spiking Neural Networks (SNNs) and Leaky Integrate-and-Fire (LIF) neurons (Vol0).
**Resolution:** Implemented an SNN that uses Arithmetic Right Shifts instead of multipliers (Vol2/v007).
**Affected Architecture:** SNN-TFF Extension.

---

### Question 005
**Question:** How do you align a 4-cycle Exact Match pipeline with a 5-cycle SNN anomaly pipeline?
**Status:** Resolved
**Evidence:** Simulation waveform showed the firewall decision arriving *after* the payload left the FPGA.
**Investigation:** Studied data delay lines and shift registers (SRL16s).
**Resolution:** Implemented an AXI-Stream Delay Line to hold the payload in transit (Vol2/v011).
**Affected Architecture:** HA-TFF System Top.
