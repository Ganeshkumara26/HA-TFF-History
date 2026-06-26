import time
import argparse
from pymavlink import mavutil

def main():
    parser = argparse.ArgumentParser(description="Extract MAVLink via UDP or TCP")
    parser.add_argument('--protocol', choices=['udp', 'tcp'], default='udp', help="Network protocol")
    parser.add_argument('--ip', type=str, default='0.0.0.0', help="IP to bind/connect")
    parser.add_argument('--port', type=int, default=14550, help="Port (usually 14550 for UDP, 5760 for TCP)")
    args = parser.parse_args()

    connection_string = ""
    if args.protocol == 'udp':
        # udpin listens for incoming telemetry from a companion computer or SITL
        connection_string = f"udpin:{args.ip}:{args.port}"
    else:
        # tcp connects to a remote server (like MAVProxy)
        connection_string = f"tcp:{args.ip}:{args.port}"

    print(f"[*] Starting MAVLink network reader on {connection_string}...")
    
    try:
        master = mavutil.mavlink_connection(connection_string)
        
        print("[*] Waiting for HEARTBEAT over the network...")
        master.wait_heartbeat()
        print(f"[+] Network Heartbeat received! (system {master.target_system})")
        
        packet_count = 0
        start_time = time.time()
        
        while True:
            # We don't block here, we want to measure packet rate
            msg = master.recv_match(type='GLOBAL_POSITION_INT', blocking=True)
            if not msg:
                continue
                
            packet_count += 1
            if packet_count % 100 == 0:
                elapsed = time.time() - start_time
                rate = packet_count / elapsed
                print(f"[STATS] Receiving at {rate:.2f} GLOBAL_POSITION packets/sec")
                
            lat = msg.lat / 1e7
            lon = msg.lon / 1e7
            # Only print every 10th message so we don't flood the console
            if packet_count % 10 == 0:
                print(f"[UDP] Lat: {lat:.6f}, Lon: {lon:.6f}")
                
    except Exception as e:
        print(f"[!] Network Error: {e}")

if __name__ == '__main__':
    main()
