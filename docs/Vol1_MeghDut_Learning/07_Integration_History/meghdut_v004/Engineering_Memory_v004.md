# Engineering Memory: MeghDut Integration v004

## Context (Week 4, Late May 2026)
Integration is complete. My teammates' dashboard is consuming my bridged MQTT telemetry perfectly. Now, it's time to test if the system scales to an enterprise level (10,000 active drones).

## The Benchmark
I wrote `mqtt_telemetry_flooder.py`, a multi-threaded Python script that simulates 10,000 unique drones sending telemetry at 10Hz. This results in a sustained load of 100,000 messages per second hitting the MQTT broker.

## The Disaster
I pointed the flooder at a local instance of the Node.js backend.
1. The CPU spiked to 100% on a single core (Node.js is single-threaded).
2. The V8 Engine started consuming massive amounts of RAM parsing 100,000 JSON strings per second.
3. To free memory, V8 triggered "Stop-The-World" Garbage Collection sweeps.
4. During these GC sweeps, the event loop froze. Telemetry latency spiked from ~2ms to over 250ms. Packets began dropping.

## The Epiphany
No amount of code optimization in `MavlinkBridge.js` will fix this. The fundamental architecture is flawed. We are asking a high-level, garbage-collected language running in an OS environment to process network packets at line rate. 

Software cannot guarantee deterministic routing for high-frequency telemetry.

## Next Steps
In `v005`, I will formally document this bottleneck and propose the hardware pivot.
