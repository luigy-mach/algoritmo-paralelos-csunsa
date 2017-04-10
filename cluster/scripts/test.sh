#!/usr/bin/expect
set USER [lindex $argv 0]
set PASS [lindex $argv 1]
set IP [lindex $argv 2]
#spawn su -s $USER
#expect "Password: "
#send  "$PASS\r"
spawn su $USER -c whoami
expect "Password: "
send  "$PASS\r"
spawn su $USER -c "ssh-keygen -t rsa"
expect "Password: "
send  "$PASS\r"
expect "Enter file in which to save the key (/home/$USER/.ssh/id_rsa): " {send "\r"}
#Overwrite (y/n)? y
#expect "Overwrite (y/n)? " 
#send  "Y\r"
expect "Enter passphrase (empty for no passphrase): " {send "\r"}
expect "Enter same passphrase again: " {send "\r"}

spawn su $USER -c "ssh $IP mkdir -p /home/$USER/.ssh"
spawn su $USER -c "cat ~/.ssh/id_rsa.pub | ssh $IP 'cat >> ~/.ssh/authorized_keys'"
spawn su $USER -c "ssh $IP \"chmod 700 .ssh; chmod 640 .ssh/authorized_keys\""



spawn su $USER -c "ssh $IP cloud -p /home/$USER/.ssh"

expect eof

