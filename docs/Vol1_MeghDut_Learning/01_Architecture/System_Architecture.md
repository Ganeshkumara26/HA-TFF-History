# MeghDut System Architecture Analysis

## Overview
MeghDut is an enterprise drone fleet management system. My teammates built the massive Node.js and React software stack. My internship task is focused purely on Hardware/Software Integration, protocol writing, and benchmarking the telemetry flow from the drones to the backend.

## Full-Stack Path
1. **ESP32 / Pixhawk (My Focus):** Transmits telemetry (lat, lng, alt, speed, battery) over MQTT using custom protocols.
2. **Backend (Teammate's Focus):** 
   - MavlinkBridge.js subscribes to the MQTT broker.
   - Parses the JSON string and forwards it to the WebSockets (TelemetryGateway.js).

## Observations
- During integration testing, I noticed the backend relies entirely on a single-threaded Node.js event loop to handle potentially thousands of MQTT messages per second.
