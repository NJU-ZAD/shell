#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo "https://netplan.io/examples/"
echo "sudo vim /etc/netplan/01-network-manager-all.yaml"
echo "sudo gedit /etc/netplan/01-network-manager-all.yaml"
echo "默认配置"
echo "# Let NetworkManager manage all devices on this system"
echo "network:"
echo "    version: 2"
echo "    renderer: NetworkManager"
echo "指定静态IP"
echo "# Let NetworkManager manage all devices on this system"
echo "network:"
echo "    version: 2"
echo "    renderer: networkd"
echo "    ethernets:"
echo "            vmnet1:"
echo "                addresses:"
echo "                    - 172.16.10.5/16"
echo "                gateway4: 172.16.0.1"
echo "            vmnet8:"
echo "                addresses:"
echo "                    - 172.16.22.8/24"
echo "                gateway4: 172.16.22.1"
read -p "按回车键继续..."
sudo netplan apply
sudo ifconfig vmnet1 down
sudo ifconfig vmnet8 down
sudo ifconfig vmnet1 up
sudo ifconfig vmnet8 up
