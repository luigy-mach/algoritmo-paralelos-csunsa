#!/usr/bin/expect
set USER [lindex $argv 0]
set PASS [lindex $argv 1]
set IP [lindex $argv 2]

spawn su $USER -c "ssh $IP mkdir -p /home/$USER/.ssh"
spawn su $USER -c "cat ~/.ssh/id_rsa.pub | ssh $IP 'cat >> ~/.ssh/authorized_keys'"
spawn su $USER -c "ssh $IP \"chmod 700 .ssh; chmod 640 .ssh/authorized_keys\""
spawn su $USER -c "ssh $IP cloud -p /home/$USER/.ssh"




expect eof

