# ADR-009: Feature Encoding Strategy

**Status:** Accepted
**Date:** Week 9 (v009)

## Context
The SNN layer expects an 8-bit spike vector. The parser outputs a 104-bit 5-tuple. We need an intermediate module (Feature Encoder) to evaluate the tuple and generate spikes representing heuristics (e.g., "Is this a known suspicious port?", "Is this UDP?").

## Options Considered

### Option A: Dynamic AXI-Lite Thresholding
Implement a configurable threshold engine where a CPU (MicroBlaze) can write to AXI-Lite memory-mapped registers to define what IP ranges and Ports trigger a spike.
- **Pros:** Highly flexible. The firewall rules can be updated dynamically.
- **Cons:** (PHYSICS FIRST: Area and Schedule constraints). Adding an AXI4-Lite interconnect, decoder, and parameter registers will triple the size of the RTL codebase. I don't have the time to build a MicroBlaze system for this iteration.

### Option B: Static Heuristics (Hardcoded RTL)
Write a Verilog module with hardcoded `if/else` statements for specific subnets and ports.
- **Pros:** Extremely fast (1 logic level of comparators). Trivial to implement.
- **Cons:** Rigid. Creates severe Control Plane Debt. If we want to change a suspicious subnet from `192.168.100.x` to `10.0.0.x`, we must recompile the FPGA bitstream.

## Decision
**Option B (Static Heuristics)** is selected.

## Engineering Justification
Given the project deadline, we accept the Control Plane Debt. The goal is to prove the hardware architecture functions at 156.25 MHz. Hardcoded comparators map beautifully to LUT6 primitives. We will log this rigidness as a major Known Issue for future work.

## Dependencies
- **Derived From:** N/A
- **Implements:** `REQ-v006`
- **Creates:** `RTL-v009/snn_feature_encoder.v`
- **Verified By:** Pending
