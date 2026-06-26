import time
import argparse
from pymavlink import mavutil

def main():
    parser = argparse.ArgumentParser(description="Extract MAVLink via OTG/Serial")
    parser.add_argument('--port', type=str, default='/dev/ttyACM0', help="Serial port (e.g. /dev/ttyACM0 or COM3)")
    parser.add_argument('--baud', type=int, default=57600, help="Baud rate")
    args = parser.parse_args()

    print(f"[*] Attempting to connect to Flight Controller on {args.port} at {args.baud} baud...")
    
    try:
        # Create the connection
        master = mavutil.mavlink_connection(args.port, baud=args.baud)
        
        # Wait for the first heartbeat 
        #   This sets the system and component ID of remote system for the link
        print("[*] Waiting for HEARTBEAT...")
        master.wait_heartbeat()
        print(f"[+] Heartbeat from system (system {master.target_system} component {master.target_component})")
        
        while True:
            # Request specific messages: GLOBAL_POSITION_INT contains lat, lon, alt, speed
            msg = master.recv_match(type=['GLOBAL_POSITION_INT', 'SYS_STATUS'], blocking=True)
            if not msg:
                continue
                
            msg_type = msg.get_type()
            
            if msg_type == 'GLOBAL_POSITION_INT':
                # PyMavlink returns lat/lon as int32 scaled by 1e7
                lat = msg.lat / 1e7
                lon = msg.lon / 1e7
                alt = msg.alt / 1000.0 # mm to meters
                print(f"[POS] Lat: {lat:.6f}, Lon: {lon:.6f}, Alt: {alt:.2f}m")
                
            elif msg_type == 'SYS_STATUS':
                battery = msg.battery_remaining
                print(f"[SYS] Battery Remaining: {battery}%")
                
    except Exception as e:
        print(f"[!] Error: {e}")

if __name__ == '__main__':
    main()
