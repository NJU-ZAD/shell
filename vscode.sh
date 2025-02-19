#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ "$1" = "1" ] || [ "$1" = "2" ]; then
        error=0
        echo "安装Visual Studio Code..."
        name=code_amd64.deb
        if [ ! -f "./$name" ]; then
            echo "正在从网络获取$name"
            if [ "$1" = "1" ]; then
                curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' --output $name
            fi
            echo "已经获取本地$name"
        fi
        sudo dpkg -i $name
        sudo apt-get -y install -f
        echo "code --version"
        code --version
        echo
        echo -e "\e[32m如果安装过程出现错误请再次运行./vscode.sh 1\e[0m"
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载Visual Studio Code..."
        sudo dpkg --purge code
        rm -rf ${HOME}/.config/Code ${HOME}/.vscode
        echo
        echo -e "\e[32m如果卸载过程出现错误请运行./vscode.sh 1后再卸载\e[0m"
    fi
fi
if [ $error = "1" ]; then
    echo "./vscode.sh 1	安装Visual Studio Code"
    echo "./vscode.sh 0	卸载Visual Studio Code"
fi
