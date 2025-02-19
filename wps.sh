#!/bin/bash
dir_input=$(xdg-user-dir DOWNLOAD)
cd $dir_input
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        echo "安装WPS Office..."
        files=$(find . -type f -name 'wps-office*amd64.deb')
        name=$files
        if [ ! -f "./$name" ]; then
            echo "访问 https://www.wps.cn/product/wpslinux 下载64位 Deb包（For X64）并再次运行./wps.sh 1"
            exit
        else
            echo "已经获取本地$name"
        fi
        sudo dpkg -i $name
        sudo apt-get -y install -f
        rm -rf $name
        echo
        echo -e "\e[32m如果安装过程出现错误请再次运行./wps.sh 1\e[0m"
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载WPS Office..."
        sudo dpkg --purge wps-office
        echo
        echo -e "\e[32m如果卸载过程出现错误请运行./wps.sh 1后再卸载\e[0m"
    fi
fi
if [ $error = "1" ]; then
    echo "./wps.sh 1	安装WPS Office"
    echo "./wps.sh 0	卸载WPS Office"
fi
