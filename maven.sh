#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
# https://maven.apache.org/download.cgi
# Binary tar.gz archive
VER=3.8.6
if [ -n "$1" ] && [ ! -n "$2" ]; then
	if [ "$1" = "1" ] || [ "$1" = "2" ]; then
		error=0
		echo "安装maven..."
		name=apache-maven-$VER-bin.tar.gz
		address=$VER/binaries/$name
		if [ ! -f "./$name" ]; then
			echo "正在从网络获取$name"
			if [ "$1" = "1" ]; then
				curl -L -O https://dlcdn.apache.org/maven/maven-3/$address
			elif [ "$1" = "2" ]; then
				sudo apt install tsocks -y
				touch tsocks.conf
				cat >tsocks.conf <<END_TEXT
server = 127.0.0.1
server_type = 5
server_port = 1080
END_TEXT
				sudo mv tsocks.conf /etc/tsocks.conf
				tsocks curl -L -O https://dlcdn.apache.org/maven/maven-3/$address
			fi
		else
			echo "已经获取本地$name"
		fi
		if [ "$JAVA_HOME" = "" ]; then
			echo "在系统中没有找到正确配置的Java"
			exit
		fi
		tar zxvf $name
		if [ -d "/usr/local/apache-maven-$VER" ]; then
			sudo rm -rf /usr/local/apache-maven-$VER
		fi
		sudo mv apache-maven-$VER /usr/local/
		shell=$(env | grep SHELL=)
		echo $shell
		if [ $shell = "SHELL=/bin/bash" ]; then
			rc=.bashrc
		else
			rc=.zshrc
		fi
		if [ $(grep -c "export PATH=\"/usr/local/apache-maven-$VER/bin:\$PATH\"" ${HOME}/$rc) -eq 0 ]; then
			echo "export PATH=\"/usr/local/apache-maven-$VER/bin:\$PATH\"" >>${HOME}/$rc
		fi
		# gedit ${HOME}/.bashrc
		# gedit ${HOME}/.zshrc
		if [ $shell = "SHELL=/bin/bash" ]; then
			gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
		else
			gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
		fi
		echo "必须在新的终端中使用mvn --version！"
	elif [ "$1" = "0" ]; then
		error=0
		echo "卸载maven..."
		sudo rm -rf /usr/local/apache-maven-$VER
		shell=$(env | grep SHELL=)
		echo $shell
		if [ $shell = "SHELL=/bin/bash" ]; then
			rc=.bashrc
		else
			rc=.zshrc
		fi
		sed -i "/apache-maven-$VER/d" ${HOME}/$rc
		if [ $shell = "SHELL=/bin/bash" ]; then
			gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
		else
			gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
		fi
	fi
fi
if [ $error -eq 1 ]; then
	echo "./maven.sh 1 安装maven"
	echo "./maven.sh 2 安装maven（socks5代理）"
	echo "./maven.sh 0 卸载maven"
fi
