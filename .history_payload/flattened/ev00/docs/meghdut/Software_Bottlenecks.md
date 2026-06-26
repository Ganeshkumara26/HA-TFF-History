# Performance & Bottleneck Analysis

## The Telemetry Bottleneck Benchmarks (May 2026)
I ran benchmarks simulating 10,000 drones emitting telemetry at 10Hz. The backend received 100,000 packets per second.

### CPU Hotspots Identified
1. **Context Switching & Network Stack:** The Linux kernel must context switch to user-space 100,000 times a second to deliver the payloads to Node.js.
2. **Serialization (JSON.parse):** Converting 100,000 byte buffers into V8 string objects, then parsing them into Javascript objects.
3. **Garbage Collection (GC):** Creating 100,000 ephemeral objects per second triggers aggressive V8 "Stop-The-World" minor GC sweeps.

## Non-Deterministic Latency
My integration metrics showed that because of the GC pauses, the time it takes for a telemetry packet to travel from the NIC to the WebSocket emitter is non-deterministic. It spiked from 2ms up to 200ms during GC sweeps.
