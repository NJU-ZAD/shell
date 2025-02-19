#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
./new.sh
sudo apt-get install build-essential gdb make gcc sshpass \
    g++ git net-tools vim htop wireshark gparted openssl \
    libssl-dev screen expect tsocks ffmpeg curl cheese -y
openssl version -a
touch tsocks.conf
cat >tsocks.conf <<END_TEXT
server = 127.0.0.1
server_type = 5
server_port = 1080
END_TEXT
sudo mv tsocks.conf /etc/tsocks.conf
