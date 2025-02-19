#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
# https://developer.nvidia.com/rdp/cudnn-archive
# *cuDNN版本由CUDA版本决定（发布日期相同）*
if [ -f '/usr/local/cuda/version.json' ]; then
    find_jq=$(dpkg -l | grep -w jq)
    if [ -z "$find_jq" ]; then
        sudo apt-get install jq -y
    fi
    cuda_ver=$(jq -r '.cuda.version' /usr/local/cuda/version.json | cut -d '.' -f 1,2)
    echo "CUDA版本号: $cuda_ver"
else
    echo "CUDA未安装"
    exit
fi
release_num=$(lsb_release -r --short)
case "$release_num" in
"22.04")
    echo -e "\e[32m获取当前Ubuntu版本$release_num\e[0m"
    ubuntu=ubuntu2204
    ;;
"20.04")
    echo -e "\e[32m获取当前Ubuntu版本$release_num\e[0m"
    ubuntu=ubuntu2004
    ;;
"18.04")
    echo -e "\e[32m获取当前Ubuntu版本$release_num\e[0m"
    ubuntu=ubuntu1804
    ;;
*)
    echo -e "\e[32m当前Ubuntu版本${release_num}不支持cuDNN\e[0m"
    exit
    ;;
esac
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        nvcc -V
        echo "正在安装适用于CUDA $cuda_ver+的cuDNN..."
        sudo apt-get install zlib1g -y
        cuda_x=$(echo "$cuda_ver" | sed 's/\.[0-9]\+/.x/')
        page_content=$(curl -s https://developer.nvidia.com/rdp/cudnn-archive)
        download_link=$(echo "$page_content" | grep -oP "https://developer.nvidia.com/downloads/compute/cudnn/secure/[^/]+/local_installers/${cuda_x}/cudnn-local-repo-${ubuntu}[^\"']+" | head -n 1)
        filename=$(basename "$download_link")
        echo "$filename"
        if [ ! -f "./$filename" ]; then
            read -p "访问 $download_link 下载deb文件至shell目录，然后按回车继续"
            echo "$download_link"
        fi
        echo "已经获取本地$filename"
        cudnn_ver=$(echo "$filename" | sed -n "s/.*${ubuntu}-\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)_.*\.deb/\1/p")
        echo "$cudnn_ver"
        sudo dpkg -i $filename
        sudo apt-get -y install -f
        sudo cp /var/cudnn-local-repo-*/cudnn-local-*-keyring.gpg /usr/share/keyrings/
        sudo apt-get update
        localvar="/var/cudnn-local-repo-${ubuntu}-${cudnn_ver}"
        libcudnn=$(ls "$localvar" | grep -E '^libcudnn[0-9]+_[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-1\+cuda[0-9]+\.[0-9]+_amd64\.deb$' | head -n 1)
        prefix=$(echo "$libcudnn" | cut -d'_' -f1)
        cuda_ver=$(echo "$libcudnn" | sed -n 's/.*cuda\([0-9]\+\.[0-9]\+\)_.*\.deb/\1/p')
        sudo apt-get install ${prefix}=$cudnn_ver-1+cuda$cuda_ver -y
        sudo apt-get install ${prefix}-dev=$cudnn_ver-1+cuda$cuda_ver -y
        sudo apt-get install ${prefix}-samples=$cudnn_ver-1+cuda$cuda_ver -y
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载cuDNN $cudnn..."
        sudo apt-get remove --purge libcudnn* libcudnn*-dev libcudnn*-samples -y
        dpkg -l | grep '^ii' | grep "cudnn-local-repo-${ubuntu}-" | awk '{print $2}' | xargs -r sudo dpkg --purge
        sudo apt autoremove
    fi
fi
if [ $error = "1" ]; then
    echo "./cudnn.sh 1	安装cuDNN"
    echo "./cudnn.sh 0	卸载cuDNN"
fi
