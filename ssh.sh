#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
if [ ! -f "../private-shell/data/ssh.txt" ]; then
	echo "../private-shell/data/ssh.txt不存在！"
	echo "../private-shell/data/ssh.txt第1行为server_user"
	echo "../private-shell/data/ssh.txt第2行为server_IP"
	echo "../private-shell/data/ssh.txt第3行为server_port"
	exit
fi
server_user=$(sed -n 1p "../private-shell/data/ssh.txt")
server_IP=$(sed -n 2p "../private-shell/data/ssh.txt")
server_port=$(sed -n 3p "../private-shell/data/ssh.txt")
specify_port=22
error=1
if [ -n "$1" ] && [ -n "$2" ]; then
	if [ $1 = "s" ] || [ $1 = "S" ]; then
		if [ $2 = "1" ]; then
			error=0

			echo -e "\e[34m以服务器端启动：\e[0m"
			echo -e "\e[31m[1]确保与客户端同处一个有效的局域网下（如手机的热点网络）\e[0m"
			echo -e "\e[31m[2]若在虚拟机中需要修改网络为桥接模式\e[0m"
			echo -e "\e[31m[3]确保已运行./ssh.sh\e[0m"
			read -p "若条件满足请按回车键继续..."
			sudo ufw allow ssh
			sudo service ssh start
			ps -e | grep ssh
			while :; do
				ifconfig
				read -p "输入服务器网卡名：" server_NIC
				inet=$(ifconfig | grep -A 1 "$server_NIC")
				OLD_IFS="$IFS"
				IFS=" "
				inets=($inet)
				IFS="$OLD_IFS"
				let "i=0"
				for var in ${inets[@]}; do
					if [ $var = "inet" ]; then
						break
					fi
					let "i=i+1"
				done
				let "i=i+1"
				server_IP=${inets[$i]}
				server_IP=$(echo "$server_IP" | sed 's/ //g')
				if [ "$server_IP" != "" ]; then
					break
				else
					echo -e "\e[31m服务器网卡名错误！\e[0m"
				fi
			done
			echo "服务器端的IPv4地址是"$server_IP
			echo "$USER" >../private-shell/data/ssh.txt
			echo "$server_IP" >>../private-shell/data/ssh.txt
			echo "$specify_port" >>../private-shell/data/ssh.txt
			cd ../private-shell
			./git_push.sh
			# vim /etc/systemd/logind.conf
			# find=$(grep -n "HandleLidSwitch=ignore" /etc/systemd/logind.conf)
			# if [ -z "$find" ]; then
			# 	sudo sed -i "s/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g" /etc/systemd/logind.conf
			# 	sudo systemctl restart systemd-logind
			# fi
		elif [ $2 = "0" ]; then
			error=0
			echo -e "\e[34m服务器端停止\e[0m"
			sudo service ssh stop
			ps -e | grep ssh
			# find=$(grep -n "#HandleLidSwitch=suspend" /etc/systemd/logind.conf)
			# if [ -z "$find" ]; then
			# 	sudo sed -i "s/HandleLidSwitch=ignore/#HandleLidSwitch=suspend/g" /etc/systemd/logind.conf
			# 	sudo systemctl restart systemd-logind
			# fi
		fi
	elif [ $1 = "c" ] || [ $1 = "C" ]; then
		if [ $2 = "1" ]; then
			error=0
			echo -e "\e[34m以客户端启动：\e[0m"
			echo -e "\e[31m[1]确保与服务器端同处一个有效的局域网下（如手机的热点网络）\e[0m"
			echo -e "\e[31m[2]若在虚拟机中需要修改网络为桥接模式\e[0m"
			read -p "若条件满足请按回车键继续..."
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
			echo -e "\e[31mssh-keygen -R [$server_IP]:$server_port\e[0m"
		elif [ $2 = "0" ]; then
			error=0
			echo "在ssh终端中执行exit命令或者直接关闭ssh终端以停止客户端"
		fi
	elif [ $1 = "p" ] || [ $1 = "P" ]; then
		if [ $2 = "1" ]; then
			error=0
			echo -e "\e[34m打开SOCKS5 SSH隧道：\e[0m"
			echo -e "\e[31m[1]确保与服务器端同处一个有效的局域网下（如手机的热点网络）\e[0m"
			echo -e "\e[31m[2]若在虚拟机中需要修改网络为桥接模式\e[0m"
			read -p "若条件满足请按回车键继续..."
			echo "ping -c 1 $server_IP"
			ping -c 1 $server_IP
			echo -e "\e[34m若无法ping通服务器说明该局域网存在问题\e[0m"
			bind_port=1080
			ssh -D $bind_port -q -C -N -f $server_user@$server_IP -p $server_port
			echo "请手动打开SOCKS5代理（全局代理）："
			echo "设置->网络->网络代理->手动->[Socks 主机] localhost ->[端口] $bind_port ->[忽略主机]=空"
		elif [ $2 = "0" ]; then
			error=0
			echo -e "\e[34m关闭SOCKS5 SSH隧道：\e[0m"
			sudo killall ssh
			echo "请手动关闭SOCKS5代理（全局代理）："
			echo "设置->网络->网络代理->已禁用"
		fi
	fi
elif [ ! -n "$1" ] && [ ! -n "$2" ]; then
	error=0
	sudo apt-get install openssh-client openssh-server -y
fi
if [ $error = "1" ]; then
	echo "./ssh.sh	安装必备软件包"
	echo "./ssh.sh s 1	作为服务器端启动"
	echo "./ssh.sh s 0	服务器端停止"
	echo "./ssh.sh c 1	作为客户端启动"
	echo -e "\e[31m支持NAT的SSH需要与~/shell/sakurafrp.sh 2配合使用\e[0m"
	echo "./ssh.sh c 2	作为客户端启动（NAT）"
	echo "./ssh.sh c 0	客户端停止"
	echo -e "\e[31mSOCKS5 SSH隧道需要与~/shell/termux/ssh.sh s 1配合使用\e[0m"
	echo "./ssh.sh p 1	打开SOCKS5 SSH隧道（可用于共享VPN网络）"
	echo "./ssh.sh p 0	关闭SOCKS5 SSH隧道"
fi
