# Engineering Memory: MeghDut Integration v003

## Context (Week 3, Late May 2026)
With MAVLink extraction working over the network, it was time to bridge it to the backend. The backend expects a specific JSON schema formatted as an MQTT message.

## The Bridging Strategy
I implemented two bridging methods for the team:
1. **Python Companion Script:** `mqtt_bridge.py`. This runs on a Raspberry Pi onboard the drone. It reads the UDP MAVLink stream and translates it to MQTT JSON.
2. **ESP32 Firmware:** `MeghdutESP32.ino`. For smaller drones without a Raspberry Pi, I wrote an ESP32 C++ sketch to read MAVLink via UART and publish it directly to HiveMQ over WiFi.

## The Result
Both methods worked. When I spun up my simulator, the React dashboard developed by my teammates successfully rendered the drone moving across the map in real-time.

## Next Steps
The protocol integration is complete. However, the system has only been tested with 1 drone. The real test of an enterprise backend is scalability. I need to write a script to simulate 10,000 drones and benchmark the backend's response.
