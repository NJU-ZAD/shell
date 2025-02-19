#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
expect <<EOF
spawn sudo apt-get install git python3 python3-dev python3-pip -y
expect "sudo"
send "123\n"
expect eof
EOF
