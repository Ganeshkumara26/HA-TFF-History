import time
import json
import threading
import argparse
import paho.mqtt.client as mqtt

def worker(worker_id, num_drones, broker):
    client = mqtt.Client(client_id=f"flooder_{worker_id}")
    client.connect(broker, 1883, 60)
    client.loop_start()
    
    # Each worker simulates `num_drones`
    while True:
        for i in range(num_drones):
            drone_id = f"DRONE_{worker_id}_{i}"
            topic = f"meghdut/telemetry/{drone_id}"
            payload = json.dumps({
                "droneId": drone_id,
                "lat": 17.3850,
                "lng": 78.4867,
                "alt": 120.5 + i,
                "battery": 85
            })
            client.publish(topic, payload, qos=0)
        # 10 Hz simulation
        time.sleep(0.1)

def main():
    parser = argparse.ArgumentParser(description="MQTT Telemetry Flooder")
    parser.add_argument('--workers', type=int, default=10, help="Number of threads")
    parser.add_argument('--drones_per_worker', type=int, default=1000, help="Drones per thread")
    parser.add_argument('--broker', type=str, default='127.0.0.1', help="MQTT Broker IP")
    args = parser.parse_args()

    total_drones = args.workers * args.drones_per_worker
    print(f"[*] Starting Flood: {total_drones} drones at 10Hz ({total_drones * 10} msgs/sec)")
    
    threads = []
    for i in range(args.workers):
        t = threading.Thread(target=worker, args=(i, args.drones_per_worker, args.broker), daemon=True)
        t.start()
        threads.append(t)
        
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[*] Stopping flood.")

if __name__ == '__main__':
    main()
