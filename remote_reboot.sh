#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
find=$(grep -i "GRUB_DEFAULT=" /etc/default/grub)
# echo $find
sudo sed -i "s#$find#GRUB_DEFAULT=0#g" /etc/default/grub
sudo update-grub
./anydesk.sh 1
reboot
