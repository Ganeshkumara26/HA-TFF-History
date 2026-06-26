# Architecture Note: v003 Cuckoo Hash Generators

## Architecture Sketch
The Hashing module acts as the first stage of the Firewall Datapath. It receives the 104-bit tuple from the Parser and computes four 12-bit addresses in parallel.

```
[ 104-bit 5-Tuple ]
       |
       +---> [ XOR Fold Seed 0 ] ---> hash_0 (12-bit)
       +---> [ XOR Fold Seed 1 ] ---> hash_1 (12-bit)
       +---> [ Shift/Mix Seed 2 ] --> hash_2 (12-bit)
       +---> [ Shift/Mix Seed 3 ] --> hash_3 (12-bit)
```

## Mathematical Model: XOR Folding
We need to compress 104 bits into 12 bits.
`104 / 12 = 8.6` chunks.
We pad the final chunk with a 4-bit static constant.

**Hash 0 (Linear Fold):**
`h0 = t[11:0] ^ t[23:12] ^ ... ^ t[95:84] ^ {4'hA, t[103:96]}`
This requires a 9-input XOR for each of the 12 output bits. 
In a 6-input LUT (LUT6) architecture like Artix-7, a 9-input XOR requires 2 LUTs per bit.
Total LUTs for Hash 0 = `12 bits * 2 LUTs/bit = 24 LUTs`.

**Hash 1 (Bit-Reversed Fold):**
To ensure `hash_1` is independent of `hash_0`, we reverse the 104-bit string before folding it.

**Hash 2 and 3 (Shift Mixing):**
Since bit-reversing is just wire routing, we need more variance. We create h2 and h3 by shifting and XORing the results of h0 and h1 with magic constants.

## Expected Timing
The longest path is calculating `h0`, shifting it, and XORing it with a constant to create `h2`.
Path: `LUT6 (h0 stage 1) -> LUT6 (h0 stage 2) -> LUT6 (h2 mix) -> Register`.
3 Logic Levels. At 156.25 MHz (6.4ns), this is extremely safe. We expect > 3.0ns of positive slack.
