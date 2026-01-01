# Code Reading: MavlinkBridge.js

## Location
MeghDut-main/backend/services/MavlinkBridge.js

## Walkthrough
Since my teammates wrote this, I had to read it to figure out why my hardware integration tests were dropping packets under load.

- **Line 67:** const payload = JSON.parse(message.toString());
  - *Engineering Note:* This is a massive red flag. JSON.parse is a blocking synchronous operation in V8. During my benchmark stress-tests, sending 5000 mock drone packets simultaneously caused the event loop to stall here.
- **Line 61:** if (!this.approvedDronesCache.has(droneId))
  - *Engineering Note:* Security validation is done via a Set lookup. If a rogue drone floods the topic with invalid droneIds, the CPU still has to execute the event callback, check the Set, and drop it. This is vulnerable to DoS.
