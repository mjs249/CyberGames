import socket
import re

def interact_with_server(host, port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        current_ammo = 0  # Initial ammo count
        ammo_type = "solid"  # Default ammo type
        
        while True:
            data = s.recv(1024).decode('utf-8')
            print("Received:", data)
            
            if "Welcome Soldier" in data:
                print("Sending Continue to start...")
                s.sendall(b"Continue\n")
                
            elif "Switching" in data:
                # Extract new weapon and ammo info if provided and reset current_ammo
                match = re.search(r"(\w+) (\w+) (\d+)", data)
                if match:
                    weapon, ammo_type, ammo_count = match.groups()
                    current_ammo = int(ammo_count)
                    print(f"Switched to {weapon} with {ammo_type} ammo and {current_ammo} count")
                print("Sending Continue after switch...")
                s.sendall(b"Continue\n")
                
            elif "Continue" in data:
                # Implement the shooting logic here
                print("Shooting...")
                for _ in range(current_ammo):
                    s.sendall(b"Shoot\n")
                # Assume we need to signal we're done shooting
                s.sendall(b"Done Shooting\n")
                
            elif "Liquid-Uses-4x-Ammo" in data and ammo_type == "liquid":
                # Adjust shooting logic for liquid ammo
                print("Adjusting for liquid ammo...")
                for _ in range(current_ammo // 4):
                    s.sendall(b"Shoot\n")
                # Adjust as needed based on actual challenge requirements
                s.sendall(b"Done Shooting\n")
                
            # Add more conditions as necessary based on challenge instructions
            
            # Placeholder for breaking out of the loop if needed
            # Adjust this condition based on when you should end interaction
            if "Mission Complete" in data or not data:
                print("Mission completed or connection closed.")
                break

if __name__ == "__main__":
    HOST, PORT = "172.18.128.76", 7676
    interact_with_server(HOST, PORT)
