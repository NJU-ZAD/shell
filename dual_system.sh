#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
# 在Ubuntu和Windows双系统中存在时间显示不正确的问题，该脚本旨在解决该问题
sudo apt-get install ntpdate -y
sudo ntpdate time.windows.com
sudo hwclock --localtime --systohc
echo "已经成功同步时间"
# sudo gedit /etc/default/grub
sudo sed -i "s#GRUB_DEFAULT=2#GRUB_DEFAULT=0#g" /etc/default/grub
sudo update-grub
echo "已经将Ubuntu设置为第一启动项"
sudo reboot
