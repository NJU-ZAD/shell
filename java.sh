#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
function config_env_var() {
	shell=$(env | grep SHELL=)
	echo $shell
	if [ $shell = "SHELL=/bin/bash" ]; then
		rc=.bashrc
	else
		rc=.zshrc
	fi
	for file in $(ls $1); do
		if [ -d $1"/"$file ]; then
			dir=$1"/"$file
			if [[ $dir = *"java"* ]] && [[ $dir = *"openjdk"* ]]; then
				if ! [[ $dir = *"."* ]]; then
					echo "获取"$dir
					if [ $(grep -c "export JAVA_HOME=\"$dir\"" ${HOME}/$rc) -eq 0 ]; then
						echo "export JAVA_HOME=\"$dir\"" >>${HOME}/$rc
					fi
					if [ $(grep -c "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" ${HOME}/$rc) -eq 0 ]; then
						echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >>${HOME}/$rc
					fi
				fi
			fi
		fi
	done
	# gedit ${HOME}/.bashrc
	# gedit ${HOME}/.zshrc
	if [ $shell = "SHELL=/bin/bash" ]; then
		gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
	else
		gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
	fi
}
if [ -n "$1" ] && [ ! -n "$2" ]; then
	if [ "$1" = "1" ]; then
		error=0
		echo "安装java..."
		sudo apt install default-jdk -y
		sudo apt install default-jre -y
		config_env_var /usr/lib/jvm
		echo "echo \$JAVA_HOME"
		echo "java -version"
		java -version
		echo "javac -version"
		javac -version
		echo "简要说明："
		echo "[1]gedit hello.java"
		echo "[2]javac hello.java"
		echo "[3]java hello"
	elif [ "$1" = "0" ]; then
		error=0
		echo -e "\e[31m注意：CUDA的某些特性依赖Java，如果已经安装了CUDA，那么卸载Java可能导致部分CUDA包依照依赖关系被删除\e[0m"
		read -p "请仔细检查卸载java带来的影响"
		sudo apt remove --purge default-jdk
		sudo apt remove --purge default-jre
		shell=$(env | grep SHELL=)
		if [ $shell = "SHELL=/bin/bash" ]; then
			rc=.bashrc
		else
			rc=.zshrc
		fi
		sed -i "/JAVA_HOME/d" ${HOME}/$rc
		if [ $shell = "SHELL=/bin/bash" ]; then
			gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
		else
			gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
		fi
	fi
fi
if [ $error -eq 1 ]; then
	echo "./java.sh 1 安装java"
	echo "./java.sh 0 卸载java"
fi
