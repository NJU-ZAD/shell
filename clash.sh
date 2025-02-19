#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
name="Clash.for.Windows-"
ver="0.20.39-x64-linux"
file=$name$ver.tar.gz
dir=$(echo $name | sed 's/\./ /g')
dir=$dir$ver
# echo $file
# echo $dir
clash_port=7890
shell=$(env | grep SHELL=)
if [ $shell = "SHELL=/bin/bash" ]; then
	rc=.bashrc
else
	rc=.zshrc
fi
if [ -n "$1" ] && [ ! -n "$2" ]; then
	if [ $1 = "h" ]; then
		error=0
		echo "[1] 访问 https://github.com/Fndroid/clash_for_windows_pkg/releases (已放弃) 下载$file"
		echo "[2] 访问 https://v2.wnet.one/#/login 注册或登录"
		echo "[3] 仪表盘 -> 一键订阅 -> 复制订阅地址"
		echo "[4] Clash for Windows"
		echo "[5] Profiles -> 点击Download from a URL右边的粘贴图标 -> Download -> Update All"
	elif [ $1 = "1" ]; then
		error=0
		echo -e "\e[34m开启网络代理\e[0m"
		dconf write /system/proxy/mode "'manual'"
		dconf write /system/proxy/http/host "'localhost'"
		dconf write /system/proxy/http/port 7890
		dconf write /system/proxy/https/host "'localhost'"
		dconf write /system/proxy/https/port 7890
		dconf write /system/proxy/ftp/host "'localhost'"
		dconf write /system/proxy/ftp/port 7890
		dconf write /system/proxy/socks/host "'localhost'"
		dconf write /system/proxy/socks/port 7890
		if [ ! -d "${HOME}/$dir/" ]; then
			if [ ! -d "$dir/" ]; then
				if [ ! -f "$file" ]; then
					echo -e "在shell中没有找到$file"
					exit
				fi
				tar -xf $file
			fi
			mv "$dir" ${HOME}/
		fi
		chmod +x "${HOME}/$dir/cfw"
		pids=$(pgrep -f "$dir")
		if [ -z "$pids" ]; then
			RDtunnel_pid=$(pgrep -u ${USER} -f "ssh -D $clash_port")
			if [ "$RDtunnel_pid" ]; then
				kill $RDtunnel_pid
			fi
			if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_CONNECTION" ]; then
				if [ $(grep -c "export http_proxy=socks5://localhost:$clash_port" ${HOME}/$rc) -eq 0 ]; then
					echo "export http_proxy=socks5://localhost:$clash_port" >>${HOME}/$rc
				fi
				if [ $(grep -c "export https_proxy=socks5://localhost:$clash_port" ${HOME}/$rc) -eq 0 ]; then
					echo "export https_proxy=socks5://localhost:$clash_port" >>${HOME}/$rc
				fi
				if [ $(grep -c "export ftp_proxy=socks5://localhost:$clash_port" ${HOME}/$rc) -eq 0 ]; then
					echo "export ftp_proxy=socks5://localhost:$clash_port" >>${HOME}/$rc
				fi
				find=$(dpkg -l | grep -w xvfb)
				if [ -z "$find" ]; then
					sudo apt-get install xvfb -y
				fi
				pkill Xvfb
				Xvfb :99 -screen 0 1024x768x24 &
				export DISPLAY=:99
			fi
			version=$(lsb_release -r | awk '{print $2}')
			case $version in
			"16.04" | "18.04" | "20.04" | "22.04")
				"${HOME}/$dir/cfw" >/dev/null 2>&1 &
				;;
			"24.04")
				"${HOME}/$dir/cfw" --no-sandbox >/dev/null 2>&1 &
				;;
			*)
				echo "Unknown version"
				;;
			esac
		fi

	elif [ $1 = "0" ]; then
		error=0
		echo -e "\e[34m关闭网络代理\e[0m"
		dconf write /system/proxy/mode "'none'"
		pids=$(pgrep -f "$dir")
		for pid in $pids; do
			kill $pid
		done
		if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_CONNECTION" ]; then
			sed -i "/localhost:$clash_port/d" ${HOME}/$rc
			pkill Xvfb
		fi
	fi
fi
if [ $error = "1" ]; then
	echo "./wnet.sh h	准备工作"
	echo "./wnet.sh 1	开启网络代理"
	echo "./wnet.sh 0	关闭网络代理"
fi
