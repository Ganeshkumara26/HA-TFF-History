# Engineering Assumptions Register

This register tracks the fundamental beliefs underpinning the architecture. Every assumption must have a validation plan and an evolving status.

---

## Assumption A-001: IPv4 / UDP / TCP Sufficiency
**Current Belief (v001):**
For this university project, parsing only IPv4 (`0x0800`), UDP (`0x11`), and TCP (`0x06`) will be sufficient to demonstrate network processing capabilities.
**Evidence:** None yet. Literature review suggests >90% of typical traffic falls in this category.
**Validation Plan:** Run PCAP traces through the parser simulation.
**Status:** `Pending Validation`

---

## Assumption A-002: Fixed Latency Parsing
**Current Belief (v001):**
We can extract the 5-tuple (Src IP, Dst IP, Src Port, Dst Port, Protocol) in exactly 4 clock cycles using a fixed-state machine, assuming no IPv4 IP-options are present (IHL=5).
**Evidence:** `RTL-v001` byte-alignment mathematical model.
**Validation Plan:** Synthesis (`SYNTH-001`) to verify 156.25 MHz timing closure, and Simulation (`SIM-001`) to confirm cycle count.
**Status:** `Pending Validation`
