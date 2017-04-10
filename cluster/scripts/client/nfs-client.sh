#!/usr/bin/expect
set USER [lindex $argv 0]
set PASS [lindex $argv 1]
set IP_SERVER [lindex $argv 2]

spawn su $USER -c "sudo -S mount -t nfs $IP_SERVER:/home/$USER/cloud ~/cloud/"
expect "Password: " 
send "$PASS\r"
expect "password for $USER: " 
send "$PASS\r"


expect eof

