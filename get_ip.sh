#!/bin/bash
if ! dpkg -l | grep -q net-tools; then
    sudo apt-get install net-tools -y
fi
if [ -n "$1" ] && [ ! -n "$2" ]; then
    net_device=$1
elif [ ! -n "$1" ]; then
    wire_device=$(ifconfig | grep -B1 'inet ' | grep -E '^en|^eth' | awk '{print $1}' | sed 's/:$//' | head -n 1)
    if [ -z "$wire_device" ]; then
        wire_state="down"
    else
        wire_state=$(cat /sys/class/net/${wire_device}/operstate 2>/dev/null)
    fi
    wireless_devices=$(iwconfig 2>/dev/null | awk '{print $1}')
    wireless_device=""
    for device in $wireless_devices; do
        if ip addr show "$device" 2>/dev/null | grep -q "inet"; then
            wireless_device="$device"
            break
        fi
    done
    if [ -z "$wireless_device" ]; then
        wireless_state="down"
    else
        wireless_state=$(cat /sys/class/net/${wireless_device}/operstate 2>/dev/null)
    fi
    net_device="none"
    if [ "$wire_state" == "up" ]; then
        # echo "Obtain a local wire card ${wire_device}"
        net_device="$wire_device"
    elif [ "$wire_state" == "down" ] && [ "$wireless_state" == "up" ]; then
        # echo "Obtain a local wireless card ${wireless_device}"
        net_device="$wireless_device"
    fi
fi
local_IP=$(ip addr show "$net_device" 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
if [ -z "$local_IP" ]; then
    local_IP="127.0.0.1"
fi
echo $local_IP
