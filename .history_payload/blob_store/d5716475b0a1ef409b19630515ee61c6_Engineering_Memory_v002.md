# Engineering Memory: MeghDut Integration v002

## Context (Week 2, May 2026)
With OTG extraction working, I moved to network extraction. MeghDut uses Companion Computers (like Raspberry Pi) onboard the drones, which forward the flight controller's MAVLink out over WiFi using UDP. 

## The Networking Step
I wrote `mavlink_network_reader.py`. I had to learn how `pymavlink` handles `udpin:` (listening as a server) versus `tcp:` (connecting as a client).
I set up an SITL (Software In The Loop) ArduPilot simulator locally and bound the script to `UDP 14550`.

## The Result
It worked beautifully. The script caught the `GLOBAL_POSITION_INT` packets over the local network. I added a small packet-rate counter, and I was receiving about 10 position updates per second.

## Next Steps
Now that I have the raw lat/lon variables in my Python script, I need to format them into a JSON payload and push them to my teammates' MQTT broker (`MavlinkBridge.js`). I will build that bridge in `v003`.
