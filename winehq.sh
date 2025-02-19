#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo "https://wiki.winehq.org/Ubuntu_zhcn"
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
	if [ "$1" = "1" ] || [ "$1" = "2" ]; then
		error=0
		echo "安装WineHQ..."
		sudo dpkg --add-architecture i386
		sudo mkdir -pm755 /etc/apt/keyrings
		sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
		release_num=$(lsb_release -r --short)
		case "$release_num" in
		"22.04")
			sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
			;;
		"20.04")
			sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
			;;
		"18.04")
			sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/winehq-bionic.sources
			libfaudio064=libfaudio0_19.07-0~bionic_amd64.deb
			libfaudio032=libfaudio0_19.07-0~bionic_i386.deb
			if [ ! -f "./$libfaudio064" ]; then
				wget -nc https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/amd64/$libfaudio064
			fi
			if [ ! -f "./$libfaudio032" ]; then
				wget -nc https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/i386/$libfaudio032
			fi
			sudo apt-get install ./$libfaudio064 -y
			sudo apt-get install ./$libfaudio032 -y
			;;
		*)
			echo "不支持的系统版本"
			exit
			;;
		esac
		sudo apt update
		if [ "$1" = "1" ]; then
			sudo apt-get install --install-recommends winehq-stable -y
		elif [ "$1" = "2" ]; then
			sudo apt-get -o Acquire::https::proxy=socks5h://localhost:7890 install --install-recommends winehq-stable -y
		fi
		echo "wine --version"
		wine --version
	elif [ "$1" = "0" ]; then
		error=0
		echo "卸载WineHQ..."
		sudo rm -rf /etc/apt/keyrings/winehq-archive.key
		sudo apt-get remove --purge winehq-stable -y
		release_num=$(lsb_release -r --short)
		case "$release_num" in
		"22.04")
			sudo rm -rf /etc/apt/sources.list.d/winehq-jammy.sources
			;;
		"20.04")
			sudo rm -rf /etc/apt/sources.list.d/winehq-focal.sources
			;;
		"18.04")
			sudo rm -rf /etc/apt/sources.list.d/winehq-bionic.sources
			;;
		*)
			echo "不支持的系统版本"
			exit
			;;
		esac
		sudo apt update
	fi
fi
if [ $error -eq 1 ]; then
	echo "./winehq.sh 1 安装WineHQ"
	echo "./winehq.sh 2 安装WineHQ（socks5代理）"
	echo "./winehq.sh 0 卸载WineHQ"
fi
