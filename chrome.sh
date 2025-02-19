#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
echo "https://www.google.com/chrome/index.html"
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ "$1" = "1" ]; then
        error=0
        echo "安装Chrome..."
        name=google-chrome-stable_current_amd64.deb
        if [ ! -f "./$name" ]; then
            echo "正在从网络获取$name"
            curl --head --max-time 3 --silent --output /dev/null --fail "www.google.com"
            if [ $? -eq 0 ]; then
                curl -Lk -O https://dl.google.com/linux/direct/$name
            else
                echo "需要GRACE！"
                exit
            fi
        else
            echo "已经获取本地$name"
        fi
        sudo dpkg -i $name
        sudo apt-get -y install -f
        echo
        echo -e "\e[32m如果安装过程出现错误请再次运行./chrome.sh 1\e[0m"
    elif [ "$1" = "0" ]; then
        error=0
        echo "卸载Chrome..."
        sudo dpkg --purge google-chrome-stable
        echo
        echo -e "\e[32m如果卸载过程出现错误请运行./chrome.sh 1后再卸载\e[0m"
    fi
fi
if [ $error -eq 1 ]; then
    echo "./chrome.sh 1 安装chrome"
    echo "./chrome.sh 0 卸载chrome"
fi
