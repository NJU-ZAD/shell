#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
	if [ $1 = "1" ]; then
		error=0
		echo "[1] 访问 https://www.natfrp.com/ 注册账号（建议使用邮箱）或管理面板"
		echo "[2] 用户 -> 实名认证"
		echo "[3] 服务 -> 隧道列表 -> 创建隧道 -> 选择节点 -> 隧道类型 -> TCP隧道 -> 本地IP|127.0.0.1 -> 本地端口|SSH (22)"
		echo "[4] 服务 -> 软件下载 -> Linux系统 -> amd64 -> 下载"
	elif [ $1 = "2" ]; then
		error=0
		echo -e "\e[34m开启内网穿透\e[0m"
		echo "已创建隧道的配置文件 -> server_addr = -> 服务器地址"
		echo "已创建隧道的配置文件 -> remote_port = -> 服务器端口"
		echo "按回车键继续..."
		read -p "注意：打开已创建隧道的配置文件，记录\"user =\"后的字符串，将其输入到接下来弹出界面的Token中"
		sudo chmod +x data/frpc_linux_amd64
		sudo data/frpc_linux_amd64
	elif [ $1 = "3" ]; then
		error=0
		echo -e "\e[34m在screen中使用sakurafrp（可选）\e[0m"
		echo "screen -S sakurafrp"
		echo "~/shell/sakurafrp.sh 1"
		echo "Ctrl+A+D"
		echo "screen -ls"
		echo "screen -r sakurafrp"
		echo "kill -9 id"
		echo "screen -wipe"
	fi
fi
if [ $error = "1" ]; then
	echo "./sakurafrp.sh 1	准备工作"
	echo "./sakurafrp.sh 2	开启内网穿透"
	echo "./sakurafrp.sh 3	在screen中使用sakurafrp（可选）"
fi
