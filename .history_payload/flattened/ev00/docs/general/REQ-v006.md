# Requirement V006: Zero-Day Anomaly Detection

## The Problem
The exact-match datapath (v005) is fast (4 cycles), but it relies on static rules. If an attacker uses a new IP address or a botnet rotates ports, the packet will slip through the hash table because the tuple is unknown. This is the definition of a Zero-Day threat.

## The Goal
The hardware must incorporate an anomaly detection engine capable of evaluating traffic *behavior* and features, rather than relying strictly on an exact IP match.

## Constraints
1. The anomaly detection must occur on the FPGA fabric at line rate (156.25 MHz).
2. It must run in parallel with the exact-match datapath.
3. Traditional Deep Learning (CNNs, Transformers) requires massive MAC (Multiply-Accumulate) arrays and floating-point math, which exceeds the DSP footprint of the Artix-7.
