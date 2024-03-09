#!/usr/bin/expect

# Set variables
set timeout -1
set host "172.18.128.76"
set port "7676"

# Connect to the server
spawn nc $host $port

# Initial reload
expect "Welcome Soldier Mission"
send -- "Reload\r"

# Main interaction loop
expect {
    "Switch" {
        # When "Switch" is detected, it's a signal to reload
        send -- "Reload\r"
        exp_continue
    }
    -re {c2ctf\{[^\}]+\}} {
        # When the flag pattern is detected, capture and print the flag
        set flag $expect_out(0,string)
        send_user "\nFlag captured: $flag\n"
        return
    }
    "Continue" {
        # When prompted with "Continue", we shoot
        send -- "Shoot\r"
        exp_continue
    }
}

# End the session if needed
send -- "exit\r"
expect eof
