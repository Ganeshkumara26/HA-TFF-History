# Engineering Memory: MeghDut Integration v001

## Context (Week 1, May 2026)
I started my internship focusing on hardware-software integration for MeghDut. My teammates are building the massive Node.js/React web backend. My job is to get telemetry off the drones and into their system.

## The First Step: OTG Serial Extraction
Before I can worry about wireless networking, I need to prove I can extract the MAVLink telemetry protocol directly from a physical Pixhawk flight controller.

I wrote `mavlink_otg_reader.py`. I connected my laptop directly to the Pixhawk via a USB OTG cable (`/dev/ttyACM0`) and ran the script.

## The Problem (Baud Rates)
Initially, the script crashed with `[!] Error: 'utf-8' codec can't decode byte 0xfe...`.
I realized MAVLink is a binary protocol, not ASCII. But more importantly, my default baud rate (57600) was wrong for USB. USB on Pixhawk usually operates at 115200. Once I fixed that, the `HEARTBEAT` message arrived.

## Next Steps
Reading from USB OTG is great for bench testing, but a drone in the sky isn't connected to my laptop via USB. I need to transition this extraction logic to run over a wireless network using UDP or TCP. I will build that in `v002`.
