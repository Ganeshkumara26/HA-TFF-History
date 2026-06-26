# Requirement V003: Exact-Match Firewall Rule Lookup

## The Problem
We can successfully parse the 104-bit 5-tuple from the 10GbE line (as proven by `v002`). However, parsing data is useless without a policy engine. We need to compare incoming 5-tuples against a list of "known bad" or "known good" flows.

## The Goal
Implement a hardware mechanism capable of exact-match lookups. Given a 104-bit tuple, the system must determine if it exists in a database of firewall rules.

## Constraints
1. The database must hold at least 4,000 rules.
2. The lookup must be deterministic and sustain 1 packet per cycle throughput.
3. Content Addressable Memory (CAM or TCAM) is too expensive and power-hungry for an Artix-7 device. We must use Block RAM (BRAM).
