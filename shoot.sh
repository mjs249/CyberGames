#!/usr/bin/expect

# Set variables
set timeout -1
set host "172.18.128.76"
set port "7676"

# Function to handle shooting until reload is needed
proc shoot { } {
    global spawn_id
    expect {
        "Shoot" {
            send -- "Shoot\r"
            exp_continue
        }
        "Reload" {
            send -- "Reload\r"
            exp_continue
        }
        "Switch" {
            # If a switch occurs, it might mean a new weapon with a new ammo count
            send -- "Continue\r"
            exp_continue
        }
        # Adjust this pattern to match how the flag is presented
        -re {ctf\{[^\}]+\}} {
            set flag $expect_out(0,string)
            send_user "Flag captured: $flag\n"
            return
        }
    }
}

# Connect to the server using nc
spawn nc $host $port

# Expect the welcome message and send 'Continue' to start
expect "Welcome Soldier Mission"
send -- "Continue\r"

# Call the shooting function to handle interaction
shoot

# End the session
send -- "exit\r"
expect eof
