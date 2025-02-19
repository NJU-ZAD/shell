#!/bin/bash
currdir=$(pwd)
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
source useful_func.sh
local_ip=$(./get_ip.sh)
port=30528
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    if [ ! -f "${HOME}/.allow_port30528" ]; then
        sudo ufw allow $port
        touch ${HOME}/.allow_port30528
    fi
fi
find=$(dpkg -l | grep -w socat)
if [ -z "$find" ]; then
    sudo apt-get install socat -y
fi
find=$(dpkg -l | grep -w wget)
if [ -z "$find" ]; then
    sudo apt-get install wget -y
fi
find=$(dpkg -l | grep -w pv)
if [ -z "$find" ]; then
    sudo apt-get install pv -y
fi

hint="用法：./download.sh 或 ./download.sh <HTTP服务器IP地址> 或 ./download.sh <HTTP服务器IP地址> <下载保存目录>"
ask="发送方是否位于相同网段或通过路由器连接的父网中(Y/n)（回答与发送方保持一致）"
save_dir=""
ROOT=0
if [ ! -n "$1" ]; then
    echo "本机IP地址为："$local_ip
    read -p "$ask" -n 1 reply
    echo
    if [ "$reply" == "Y" ] || [ "$reply" == "y" ]; then
        while true; do
            read -p "输入HTTP服务器的IP地址：" ip
            res=$(validate_ip "$ip")
            if [ $res -eq 1 ]; then
                break
            fi
        done
    fi
elif [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ "$1" == "-h" ] || [ "$1" == "-H" ]; then
        echo $hint
        exit
    else
        echo "本机IP地址为："$local_ip
        ip="$1"
        res=$(validate_ip "$ip")
        if [ $res -eq 0 ]; then
            echo "HTTP服务器IP地址格式错误"
            exit
        fi
        read -p "$ask" -n 1 reply
        echo
    fi
elif [ -n "$1" ] && [ -n "$2" ] && [ ! -n "$3" ]; then
    echo "本机IP地址为："$local_ip
    ip="$1"
    res=$(validate_ip "$ip")
    if [ $res -eq 0 ]; then
        echo "HTTP服务器IP地址格式错误"
        exit
    fi
    cd $currdir
    save_dir=$(realpath "$2")
    cd $dir_input
    if [ ! -d "$save_dir" ]; then
        echo "下载保存目录不存在"
        exit
    fi
    if [[ "$save_dir" != /home/* ]]; then
        echo "下载保存目录不应为系统目录"
        exit
    fi
    if [[ "$save_dir" != ${HOME}/* ]] && [ "$save_dir" != "${HOME}" ]; then
        ROOT=1
    fi
    read -p "$ask" -n 1 reply
    echo
else
    echo $hint
    exit
fi
if [ -z "$save_dir" ]; then
    save_dir="download.sh的下载"
    mkdir -p $save_dir
fi

auto_root() {
    root="$1"
    command="$2"
    shift 2
    if [ $root -eq 1 ]; then
        sudo $command "$@"
    else
        $command "$@"
    fi
}

if [ "$reply" == "Y" ] || [ "$reply" == "y" ]; then
    if ! ping -c 1 $ip &>/dev/null; then
        echo "${ip}不可达"
        exit
    fi
    url="http://${ip}:$port"
    head_url=$(wget --no-proxy -qO- "$url" | grep -oP '(?<=href=")[^"]*(?=")' | head -n 1)
    if [ -z "$head_url" ]; then
        echo "未找到可下载的文件"
        exit 1
    fi
    if [[ "$head_url" == */ ]]; then
        auto_root $ROOT wget --no-proxy --restrict-file-names=nocontrol -r -np -nH --cut-dirs=0 -R "index.html*,robots.txt,index.html.tmp" -P $save_dir $url
    else
        filename=$(basename "$head_url" | perl -MURI::Escape -ne 'print uri_unescape($_)')
        auto_root $ROOT wget --no-proxy "$url/$head_url" -O "$save_dir/$filename"
    fi
else
    temp_file="${save_dir}/shell_download_sh_temp_out"
    if [ -f "$temp_file" ]; then
        temp_file="${temp_file}_"
    fi
    auto_root $ROOT touch ${temp_file}
    socat TCP4-LISTEN:$port -
    sleep 1
    auto_root $ROOT ./_socat.sh $port "${temp_file}" "${save_dir}"
    filetype=$(sed -n 1p "${temp_file}")
    filename=$(sed -n 2p "${temp_file}")
    auto_root $ROOT rm -rf ${temp_file}
    if [ "$filetype" == "d2" ]; then
        cd ${save_dir}
        auto_root $ROOT mv "${filename}" "${filename}.tar"
        auto_root $ROOT tar -xf "${filename}.tar"
        auto_root $ROOT rm -rf "${filename}.tar"
    fi
fi

if [[ $filename =~ \.zip$ ]]; then
    read -p "下载的文件是zip压缩包，是否解压？(Y/n)" -n 1 extract
elif [[ $filename =~ \.rar$ ]]; then
    read -p "下载的文件是rar压缩包，是否解压？(Y/n)" -n 1 extract
elif [[ $filename =~ \.7z$ ]]; then
    read -p "下载的文件是7z压缩包，是否解压？(Y/n)" -n 1 extract
elif [[ $filename =~ \.tar$ ]]; then
    read -p "下载的文件是tar包，是否解压？(Y/n)" -n 1 extract
elif [[ $filename =~ \.tar\.gz$ ]]; then
    read -p "下载的文件是tar.gz包，是否解压？(Y/n)" -n 1 extract
elif [[ $filename =~ \.tar\.tgz$ ]]; then
    read -p "下载的文件是tar.tgz包，是否解压？(Y/n)" -n 1 extract
elif [[ $filename =~ \.tgz$ ]]; then
    read -p "下载的文件是.tgz包，是否解压？(Y/n)" -n 1 extract
elif [[ $filename =~ \.tar\.xz$ ]]; then
    read -p "下载的文件是tar.xz包，是否解压？(Y/n)" -n 1 extract
elif [[ $filename =~ \.gz$ ]]; then
    read -p "下载的文件是.gz包，是否解压？(Y/n)" -n 1 extract
else
    exit
fi
echo

if [ "$extract" = "Y" ] || [ "$extract" = "y" ]; then
    cd $save_dir
    case "$filename" in
    *.zip)
        auto_root $ROOT unzip "$filename"
        ;;
    *.rar)
        find=$(dpkg -l | grep -w unrar)
        if [ -z "$find" ]; then
            sudo apt-get install unrar -y
        fi
        auto_root $ROOT unrar x "$filename"
        ;;
    *.7z)
        find=$(dpkg -l | grep -w p7zip-full)
        if [ -z "$find" ]; then
            sudo apt-get install p7zip-full -y
        fi
        auto_root $ROOT 7z x "$filename"
        ;;
    *.tar | *.tar.gz | *.tar.tgz | *.tgz)
        auto_root $ROOT tar -xvf "$filename"
        ;;
    *.tar.xz)
        auto_root $ROOT xz -d "$filename"
        auto_root $ROOT tar -xvf "${filename%.*}"
        ;;
    *.gz)
        auto_root $ROOT gzip -d "$filename"
        ;;
    esac
fi
