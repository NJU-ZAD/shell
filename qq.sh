#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
# https://im.qq.com/linuxqq/index.shtml
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        echo "安装QQ..."
        sudo apt install libgtk2.0-0 -y
        qq_url=$(curl -s "https://im.qq.com/linuxqq/index.shtml" | grep -oP '(http|https)://[^"]*linuxQQDownload[^"]*')
        qq_url=$(curl -s $qq_url | grep -o 'https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_.*_amd64_01.deb' | head -n 1)
        name=QQ_amd64_01.deb
        if [ ! -f "./$name" ]; then
            echo "正在从网络获取$name"
            curl -Lk $qq_url --output $name
        else
            echo "已经获取本地$name"
        fi
        sudo dpkg -i $name
        sudo apt-get -y install -f
        echo "如果版本更新后登录出现闪退情况，运行rm -rf ~/.config/tencent-qq/[你的QQ号]后重新登录。"
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载QQ..."
        sudo dpkg -r linuxqq
        sudo dpkg --purge linuxqq
    fi
fi
if [ $error = "1" ]; then
    echo "./qq.sh 1	安装QQ"
    echo "./qq.sh 0	卸载QQ"
    exit
fi
