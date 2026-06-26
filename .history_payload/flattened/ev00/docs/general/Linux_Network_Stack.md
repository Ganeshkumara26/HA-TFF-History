# The Linux Network Stack & The Cost of Software

## Context
During my MeghDut integration (`meghdut_v004`), my Python flooder completely destroyed the Node.js backend. I am trying to understand *why* at a kernel level.

## Journey of a Packet
When my `UDP 14550` packet arrives at the server:
1. **NIC (Hardware):** Receives the electrical signals, verifies the FCS (CRC), and writes the packet to a Ring Buffer in RAM using DMA (Direct Memory Access).
2. **Interrupt (Hardware -> OS):** The NIC fires an IRQ to tell the CPU "Hey, I have data".
3. **NAPI (Kernel):** The Linux kernel pauses its current thread (Context Switch) and pulls the packet out of the Ring Buffer. It allocates an `sk_buff` (Socket Buffer) structure in kernel memory.
4. **Netfilter (Kernel):** The packet passes through iptables/ufw rules. (Software filtering).
5. **Socket (Kernel -> User):** The kernel copies the data from kernel-space to user-space so Node.js can read it. (Memory Copy).
6. **V8 Engine (User):** Node.js reads the buffer, creates a Javascript String, and calls `JSON.parse()`.
7. **Garbage Collection (User):** The ephemeral strings trigger a minor GC sweep.

## The Bottleneck
Steps 2, 3, 5, 6, and 7 all consume CPU cycles and introduce unpredictable latency. 

## The Hardware Pivot
If I can intercept the packet at Step 1, using an FPGA sitting between the physical wire and the NIC, I can drop invalid packets in exactly 1 clock cycle (6.4ns at 156.25 MHz). The CPU will never receive the interrupt. The kernel will never allocate the `sk_buff`. The Node.js event loop will never stall.

This is the justification for the Traffic Filter Firewall.
