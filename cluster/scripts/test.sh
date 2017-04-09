#!/usr/bin/expect
set USER [lindex $argv 0]
set PASS [lindex $argv 1]
#spawn su -s $USER
#expect "Password: "
#send  "$PASS\r"
spawn su $USER -c whoami
expect "Password: "
send  "$PASS\r"
#spawn ssh-keygen -t dsa
#expect "Enter file in which to save the key (/home/test9/.ssh/id_dsa): " {send "\r"}
#Overwrite (y/n)? y
#expect "Enter passphrase (empty for no passphrase): " {send "\r"}
#expect "Enter same passphrase again: " {send "\r"}
expect eof


