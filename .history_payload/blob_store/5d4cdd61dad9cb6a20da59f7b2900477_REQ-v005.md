# Requirement V005: Firewall Datapath Integration

## The Problem
We have the Parser (`v002`), the Hash Generator (`v003`), and the Memory Banks (`v004`), but they exist in isolation.

## The Goal
Create a Top-Level Datapath module that stitches these components together and instantiates a "Matcher" module. The Matcher must compare the 4 outputs from the BRAM banks against the original parsed tuple to see if there is a match, resolving the firewall decision (Drop or Forward).

## Constraints
1. The datapath must maintain pipelined execution.
2. Timing closure must be met at 156.25 MHz.
