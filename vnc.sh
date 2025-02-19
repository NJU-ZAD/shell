#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
if [ ! -f "../private-shell/data/vnc.txt" ]; then
	echo "../private-shell/data/vnc.txt不存在！"
	echo "../private-shell/data/vnc.txt第1行为server_IP"
	exit
fi
server_IP=$(sed -n 1p "../private-shell/data/vnc.txt")
server_port=5900
error=1
if [ -n "$1" ] && [ -n "$2" ]; then
	if [ $1 = "s" ] || [ $1 = "S" ]; then
		if [ $2 = "1" ]; then
			error=0
			echo -e "\e[34m以服务器端启动：\e[0m"
			echo -e "\e[31m[1]确保与客户端同处一个有效的局域网下（如手机的热点网络）\e[0m"
			echo -e "\e[31m[2]若在虚拟机中需要修改网络为桥接模式\e[0m"
			read -p "若条件满足请按回车键继续..."
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
			echo "$server_IP" >../private-shell/data/vnc.txt
			cd ../private-shell
			./git_push.sh
			sudo ufw allow $server_port
			sudo /sbin/iptables -I INPUT 1 -p TCP --dport $server_port -j ACCEPT
			sudo iptables save
			sudo service vncserver restart
			sudo x11vnc -forever -shared -rfbauth ${HOME}/.vnc/passwd -ncache 25
		elif [ $2 = "0" ]; then
			error=0
			echo -e "\e[34m服务器端停止\e[0m"
			echo "在终端执行Ctrl+C以停止VNC服务"
		fi
	fi
elif [ -n "$1" ] && [ ! -n "$2" ]; then
	if [ $1 = "1" ]; then
		error=0
		sudo apt-get install x11vnc -y
		x11vnc -storepasswd
		# https://www.realvnc.com/download/viewer/linux/
		VER=6.22.515
		VNC_Viewer=VNC-Viewer-$VER-Linux-x64.deb
		if [ ! -f "$VNC_Viewer" ]; then
			curl -L -O https://downloads.realvnc.com/download/file/viewer.files/$VNC_Viewer
		fi
		sudo dpkg -i $VNC_Viewer
		sudo apt-get -y install -f
	elif [ $1 = "0" ]; then
		error=0
		sudo apt-get --purge remove x11vnc -y
		sudo dpkg --purge realvnc-vnc-viewer
		sudo apt autoremove -y
	elif [ $1 = "c" ] || [ $1 = "C" ]; then
		error=0
		echo -e "\e[34m以客户端启动：\e[0m"
		echo "ping -c 1 $server_IP"
		ping -c 1 $server_IP
		echo -e "\e[34m若无法ping通服务器说明该局域网存在问题\e[0m"
		vncviewer $server_IP
	fi
fi
if [ $error = "1" ]; then
	echo -e "\e[32mVNC精确显示显卡输出的图像副本。如果显卡没有输出图形，VNC将无法显示远程设备的用户界面。实际上，无需将显示器连接到远程设备，将虚拟插头连接到远程设备就够了（例如HDMI转VGA转换器）\e[0m"
	echo
	echo "通过x11vnc -storepasswd修改VNC密码"
	echo "./vnc.sh 1	安装必备软件包"
	echo "./vnc.sh 0	卸载必备软件包"
	echo "./vnc.sh s 1	作为服务器端启动"
	echo "./vnc.sh s 0	服务器端停止"
	echo "./vnc.sh c	运行客户端"
fi
