#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
if [ ! -f "../../private-shell/data/ssh.txt" ]; then
	echo "../../private-shell/data/ssh.txt不存在！"
	echo "../../private-shell/data/ssh.txt第1行为server_user"
	echo "../../private-shell/data/ssh.txt第2行为server_IP"
	echo "../../private-shell/data/ssh.txt第3行为server_port"
	exit
fi
server_user=$(sed -n 1p "../../private-shell/data/ssh.txt")
server_IP=$(sed -n 2p "../../private-shell/data/ssh.txt")
server_port=$(sed -n 3p "../../private-shell/data/ssh.txt")
specify_port=22
error=1
if [ -n "$1" ] && [ -n "$2" ]; then
	if [ $1 = "s" ] || [ $1 = "S" ]; then
		if [ $2 = "1" ]; then
			error=0
			echo -e "\e[34m以服务器端启动：\e[0m"
			echo -e "\e[31m[1]确保与客户端同处一个有效的局域网下（如手机的热点网络）\e[0m"
			echo -e "\e[31m[2]若在虚拟机中需要修改网络为桥接模式\e[0m"
			echo -e "\e[31m[3]确保已运行./ish/ssh.sh\e[0m"
			read -p "若条件满足请按回车键继续..."
			sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
			echo "vim /etc/ssh/sshd_config"
			/usr/sbin/sshd
			ps -e | grep ssh
			read -p "输入服务器端的IPv4地址：" server_IP
			echo "$USER" >../../private-shell/data/ssh.txt
			echo "$server_IP" >>../../private-shell/data/ssh.txt
			echo "$specify_port" >>../../private-shell/data/ssh.txt
			cd ../../private-shell
			./git_push.sh
		elif [ $2 = "0" ]; then
			error=0
			echo -e "\e[34m服务器端停止\e[0m"
			pkill sshd
			ps -e | grep ssh
		fi
	elif [ $1 = "c" ] || [ $1 = "C" ]; then
		if [ $2 = "1" ]; then
			error=0
			echo -e "\e[34m以客户端启动：\e[0m"
			echo -e "\e[31m[1]确保与服务器端同处一个有效的局域网下（如手机的热点网络）\e[0m"
			echo -e "\e[31m[2]若在虚拟机中需要修改网络为桥接模式\e[0m"
			read -p "若条件满足请按回车键继续..."
			echo "ping -c 1 $server_IP"
			ping -c 1 $server_IP
			echo -e "\e[34m若无法ping通服务器说明该局域网存在问题\e[0m"
			ssh $server_user@$server_IP -p $server_port
		elif [ $2 = "2" ]; then
			error=0
			echo -e "\e[34m以客户端启动（NAT）：\e[0m"
			server_IP=$(sed -n 1p "${HOME}/private-shell/data/sakurafrp.txt")
			server_port=$(sed -n 2p "${HOME}/private-shell/data/sakurafrp.txt")
			ping -c 1 $server_IP
			ssh $server_user@$server_IP -p $server_port
			echo
			echo -e "\e[31m当出现REMOTE HOST IDENTIFICATION HAS CHANGED时应执行\e[0m"
			echo -e "\e[31msed -i '/\[$server_IP\]\:$server_port/d' /root/.ssh/known_hosts\e[0m"
		elif [ $2 = "0" ]; then
			error=0
			echo "在ssh终端中执行exit命令或者直接关闭ssh终端以停止客户端"
		fi
	fi
elif [ ! -n "$1" ] && [ ! -n "$2" ]; then
	error=0
	sed -i 's#apk.ish.app/v3.14-2023-05-19#mirrors.tuna.tsinghua.edu.cn/alpine/v3.14#g' /etc/apk/repositories
	apk add openssh
	ssh-keygen -A
	passwd
fi
if [ $error = "1" ]; then
	echo "./ssh.sh	安装必备软件包"
	echo "./ssh.sh s 1	作为服务器端启动"
	echo "./ssh.sh s 0	服务器端停止"
	echo "./ssh.sh c 1	作为客户端启动"
	echo -e "\e[31m支持NAT的SSH需要与~/shell/sakurafrp.sh 2配合使用\e[0m"
	echo "./ssh.sh c 2	作为客户端启动（NAT）"
	echo "./ssh.sh c 0	客户端停止"
fi
