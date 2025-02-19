#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
echo "https://www.microsoft.com/edge/download"
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ "$1" = "1" ]; then
        error=0
        echo "安装Microsoft Edge..."
        page_content=$(curl -s https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/)
        links=$(echo "$page_content" | grep -oP 'href="microsoft-edge-stable_[^"]+_amd64\.deb"')
        latest_link=$(echo "$links" | sort -V | tail -n 1 | grep -oP 'microsoft-edge-stable_[^"]+_amd64\.deb')
        edge_url="https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/$latest_link"
        name=microsoft-edge-stable_amd64.deb
        if [ ! -f "./$name" ]; then
            echo "正在从网络获取$name"
            curl -Lk $edge_url --output $name
        else
            echo "已经获取本地$name"
        fi
        sudo dpkg -i $name
        sudo apt-get -y install -f
        echo
        echo -e "\e[32m如果安装过程出现错误请再次运行./edge.sh 1\e[0m"
    elif [ "$1" = "0" ]; then
        error=0
        echo "卸载Microsoft Edge..."
        sudo dpkg --purge microsoft-edge-stable
        echo
        echo -e "\e[32m如果卸载过程出现错误请运行./edge.sh 1后再卸载\e[0m"
    fi
fi
if [ $error -eq 1 ]; then
    echo "./edge.sh 1 安装Microsoft Edge"
    echo "./edge.sh 0 卸载Microsoft Edge"
fi
