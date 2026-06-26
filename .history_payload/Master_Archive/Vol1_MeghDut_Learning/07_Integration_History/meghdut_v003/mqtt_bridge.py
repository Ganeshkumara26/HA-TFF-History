import json
import time
import argparse
import paho.mqtt.client as mqtt
from pymavlink import mavutil

def main():
    parser = argparse.ArgumentParser(description="Bridge MAVLink UDP to MQTT")
    parser.add_argument('--drone_id', type=str, default='DRONE_001', help="Drone ID for MeghDut Backend")
    parser.add_argument('--broker', type=str, default='broker.hivemq.com', help="MQTT Broker IP")
    args = parser.parse_args()

    topic = f"meghdut/telemetry/{args.drone_id}"
    
    print(f"[*] Connecting to MQTT Broker at {args.broker}...")
    client = mqtt.Client(client_id=f"bridge_{args.drone_id}")
    client.connect(args.broker, 1883, 60)
    client.loop_start()

    print("[*] Listening for local MAVLink on UDP 14550...")
    master = mavutil.mavlink_connection('udpin:0.0.0.0:14550')
    master.wait_heartbeat()
    
    while True:
        msg = master.recv_match(type=['GLOBAL_POSITION_INT', 'SYS_STATUS'], blocking=True)
        if not msg:
            continue
            
        payload = {"droneId": args.drone_id}
        
        if msg.get_type() == 'GLOBAL_POSITION_INT':
            payload.update({
                "lat": msg.lat / 1e7,
                "lng": msg.lon / 1e7,
                "alt": msg.alt / 1000.0,
                "heading": msg.hdg / 100.0 if hasattr(msg, 'hdg') else 0.0
            })
        elif msg.get_type() == 'SYS_STATUS':
            payload.update({
                "battery": msg.battery_remaining
            })
            
        # Serialize to JSON and publish
        json_payload = json.dumps(payload)
        client.publish(topic, json_payload)
        print(f"[PUBLISH] {topic} -> {json_payload}")

if __name__ == '__main__':
    main()
