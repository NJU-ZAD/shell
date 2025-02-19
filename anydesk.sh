#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
# https://anydesk.com.cn/zhs
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        echo "安装AnyDesk..."
        anydesk_url=$(curl -s "https://anydesk.com.cn/zhs/downloads/thank-you?dv=deb_64" | grep -o 'https://download.anydesk.com/linux/anydesk_.*_amd64.deb' | head -n 1)
        name=anydesk_amd64.deb
        if [ ! -f "./$name" ]; then
            echo "正在从网络获取$name"
            curl -L $anydesk_url --output $name
        else
            echo "已经获取本地$name"
        fi
        sudo dpkg -i $name
        sudo apt-get -y install -f
        echo
        echo -e "\e[32m如果安装过程出现错误请再次运行./anydesk.sh 1\e[0m"
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载AnyDesk..."
        sudo dpkg --purge anydesk
        sudo apt-get autoremove -y
        echo
        echo -e "\e[32m如果卸载过程出现错误请运行./anydesk.sh 1后再卸载\e[0m"
    fi
fi
if [ $error = "1" ]; then
    echo "./anydesk.sh 1	安装AnyDesk"
    echo "./anydesk.sh 0	卸载AnyDesk"
fi
