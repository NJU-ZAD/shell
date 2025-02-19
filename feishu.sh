#!/bin/bash
dir_input=$(xdg-user-dir DOWNLOAD)
cd $dir_input
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        echo "安装飞书..."
        files=$(find . -type f -name 'Feishu-linux_x64-*.deb')
        name=$(echo $files | awk '{print $1}')
        if [ ! -f "$name" ]; then
            echo "访问 https://www.feishu.cn/download 选择Linux Deb包（X64）保存至[主目录/下载]并再次运行./feishu.sh 1"
            exit
        else
            echo "已经获取本地$name"
        fi
        sudo dpkg -i $name
        sudo apt-get -y install -f
        rm -rf $name
        echo
        echo -e "\e[32m如果安装过程出现错误请再次运行./feishu.sh 1\e[0m"
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载飞书..."
        sudo dpkg --purge bytedance-feishu-stable
        echo
        echo -e "\e[32m如果卸载过程出现错误请运行./feishu.sh 1后再卸载\e[0m"
    fi
fi
if [ $error = "1" ]; then
    echo "./feishu.sh 1	安装飞书"
    echo "./feishu.sh 0	卸载飞书"
fi
