#!/usr/bin/expect
set timeout 20
set ip [lindex $argv 0]
set port [lindex $argv 1]


spawn telnet $ip $port
expect "'^]'."
sleep .1

send "reload wsagent agent.agent_login\r"
expect "<CMD OK>"

send "reload wsagent agent.agent_room\r"
expect "<CMD OK>"

exit

##reload wsagent agent.agent_room

