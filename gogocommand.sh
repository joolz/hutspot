#!/usr/bin/expect -f

spawn telnet localhost 11311

expect "g!"

send "lb nl-ou-dlwo-courseplan\r"

sleep 5
