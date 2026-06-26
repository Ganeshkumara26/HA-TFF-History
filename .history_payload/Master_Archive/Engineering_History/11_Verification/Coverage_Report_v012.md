# Verification Coverage Report v012

## Verified Successfully
- [x] Normal valid TCP packet
- [x] Normal valid UDP packet
- [x] Threat matched in Cuckoo Hash (Drop triggered)
- [x] Threat matched by SNN Anomaly (Drop triggered)
- [x] Endian-byte swapping on 64-bit boundaries

## Unverified / Ignored
- [ ] IPv4 packets with IP Options (IHL > 5).
- [ ] Fragmented IP packets.
- [ ] IPv6.
- [ ] VLAN Tagged (802.1Q) frames.
- [ ] ICMP packets.
