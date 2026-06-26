# AXI4-Stream Protocol

## Concept
The Advanced eXtensible Interface (AXI) Stream is how Xilinx IPs pass streaming data (like network packets) around an FPGA.
Unlike AXI-Lite, there are no addresses. Data just flows from Master to Slave.

## The Signals
- `aclk`: The clock (156.25 MHz for 10GbE).
- `aresetn`: Active-low reset.
- `tvalid`: The Master says "I have valid data on the bus".
- `tready`: The Slave says "I am ready to accept data".
- `tdata`: The actual payload (64 bits).
- `tkeep`: A byte-enable mask (8 bits). If it's the last word of a packet, and the packet isn't perfectly divisible by 8, `tkeep` tells us which bytes in `tdata` are real.
- `tlast`: Asserts HIGH on the final clock cycle of the packet.

## The Golden Handshake Rule
Data is transferred ONLY on the rising edge of `aclk` when BOTH `tvalid` == 1 AND `tready` == 1.
If `tvalid` is high but `tready` is low, the Master MUST hold `tdata` steady. It cannot drop the packet.

## My Design Implication
My Traffic Filter Firewall will be an AXI-Stream slave to the MAC, and an AXI-Stream Master to the PCIe endpoint.
I must NEVER drop `tready` if I can avoid it, because dropping `tready` causes backpressure, which eventually fills the MAC's FIFO and drops packets on the floor. I must design the pipeline to process 1 word every single clock cycle unconditionally.
