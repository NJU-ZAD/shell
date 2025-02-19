#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
#./clear.sh 1表示允许执行apt-get autoremove
echo "删除软件包缓存..."
sudo apt-get clean -y
sudo apt-get autoclean -y
pip cache purge
if [ -n "$1" ]; then
	if [ $1 -eq "1" ]; then
		echo "执行sudo apt-get autoremove..."
		sudo apt-get autoremove
	fi
fi
echo "清空bash历史命令，下次登入有效..."
history -c
sudo rm -rf ${HOME}/.bash_history ${HOME}/.zsh_history
if [ -d ${HOME}/.cache/vmware/ ]; then
	echo "删除虚拟机和主机间文件拷贝的缓存..."
	sudo rm -rf ${HOME}/.cache/vmware/
fi
echo
echo "查看当前Ubuntu系统使用的内核："
echo "uname -a"
uname -a
echo "查看系统所有内核："
echo "dpkg --get-selections|grep linux"
echo "删除系统多余的老旧内核："
echo "sudo apt-get --purge remove "
echo "更新系统引导："
echo "sudo update-grub"
