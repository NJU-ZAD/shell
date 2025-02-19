#!/bin/bash
currdir=$(pwd)
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
source useful_func.sh
ip=$(./get_ip.sh)
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
find=$(dpkg -l | grep -w pv)
if [ -z "$find" ]; then
    sudo apt-get install pv -y
fi

hint="用法：./share.sh 或 ./share.sh <待分享文件（夹）的路径>"
ROOT=0
if [ ! -n "$1" ]; then
    echo "本机IP地址为："$ip
    temp="${HOME}/.temp_file_list.txt"
    find . -maxdepth 1 ! -name "*.sh" ! -path "./.git" ! -path "." >$temp
    file_list=()
    i=0
    while IFS= read -r line; do
        file_list+=("$line")
        echo "$i) $line"
        ((i++))
    done <$temp
    file_count=${#file_list[@]}
    # echo $file_count
    while :; do
        read -p "选择要分享文件（夹）的编号或其他文件（夹）的绝对路径：" input
        if [[ $input =~ ^[0-9]+$ ]] && [ $input -ge 0 ] && [ $input -lt $file_count ]; then
            target=${file_list[$input]}
            break
        else
            target=$(echo "$input" | sed "s|^~|${HOME}|")
            if [ ! -e "$target" ]; then
                echo "输入错误或路径不存在"
            else
                break
            fi
        fi
    done
    rm -rf $temp
elif [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ "$1" == "-h" ] || [ "$1" == "-H" ]; then
        echo $hint
        exit
    else
        echo "本机IP地址为："$ip
        cd $currdir
        target=$(realpath "$1")
        cd $dir_input
        if [ ! -e "$target" ]; then
            echo "文件（夹）路径不存在"
            exit
        fi
        if [[ "$target" == "/" ]]; then
            echo "无法发送根目录"
            exit
        fi
        if [[ "$target" != ${HOME}/* ]]; then
            ROOT=1
        fi
    fi
else
    echo $hint
    exit
fi

read -p "接收方是否位于相同网段或通过路由器连接的子网中(Y/n)" -n 1 reply
echo
targetname=$(basename "$target")
work_dir=$(dirname "$target")
if [ "$reply" == "N" ] || [ "$reply" == "n" ]; then
    while true; do
        read -p "输入接收方的IP地址：" rip
        res=$(validate_ip "$rip")
        if [ $res -eq 1 ]; then
            break
        fi
    done
    if ! ping -c 1 $rip &>/dev/null; then
        echo "${rip}不可达"
        exit
    fi

    first=1
    while true; do
        echo "ok" | socat - TCP4:$rip:$port >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            break
        else
            if [ $first -eq 1 ]; then
                echo "等待接收方就绪..."
                sleep 2
                first=0
            fi
        fi
    done
    sleep 2

    filetype="f"
    sendname=${targetname}
    if [ -d "$target" ]; then
        read -p "在传输前是否压缩该文件夹(Y/n)" -n 1 com
        echo
        cd "$work_dir"
        if [ $ROOT -eq 1 ]; then
            com_output="${HOME}"
        else
            com_output="."
        fi
        if [ "$com" = "Y" ] || [ "$com" = "y" ]; then
            filetype="d1"
            zip -r "${com_output}/${targetname}.zip" "$targetname"
            filesize=$(stat -c%s "${com_output}/${targetname}.zip")
            content="${com_output}/${targetname}.zip"
            sendname="${targetname}.zip"
        else
            filetype="d2"
            tar -cf "${com_output}/${targetname}.tar" "$targetname"
            filesize=$(stat -c%s "${com_output}/${targetname}.tar")
            content="${com_output}/${targetname}.tar"
        fi
    else
        filesize=$(stat -c%s "$target")
        content="$target"
    fi
    {
        echo "$filetype"
        echo "$sendname"
        echo "$filesize"
        cat "$content"
    } | pv | env -u http_proxy -u https_proxy -u all_proxy socat - TCP4:$rip:$port
    if [ -d "$target" ]; then
        rm -rf "${com_output}/${targetname}.zip" "${com_output}/${targetname}.tar"
    fi
else
    if [ $ROOT -eq 1 ]; then
        http_server_dir="${HOME}/transfer_tmp/"
    else
        http_server_dir="$work_dir/transfer_tmp/"
    fi
    mkdir -p "$http_server_dir"
    if [ "$(ls -A "$http_server_dir")" ]; then
        read -p "警告：${http_server_dir}中存在重要的文件或目录，这可能是由于share.sh的上次执行被强制中断，请将它们移动至他处然后回车继续"
    fi
    if [ -d "$target" ]; then
        read -p "在传输前是否压缩该文件夹(Y/n)" -n 1 com
        echo
        if [ "$com" = "Y" ] || [ "$com" = "y" ]; then
            cd "$work_dir"
            zip -r "${http_server_dir}/${targetname}.zip" "$targetname"
        else
            if [ $ROOT -eq 1 ]; then
                cp -r "$target" "$http_server_dir"
            else
                mv "$target" "$http_server_dir"
            fi
        fi
    else
        if [ $ROOT -eq 1 ]; then
            cp "$target" "$http_server_dir"
        else
            mv "$target" "$http_server_dir"
        fi
    fi

    cd "$http_server_dir"
    server_pid=$(pgrep -u ${USER} -f 'python3 -m http.server')
    if [ "$server_pid" ]; then
        kill $server_pid
    fi
    python3 -m http.server $port >/dev/null 2>&1 &
    server_pid=$!
    echo
    echo "已共享：http://$ip:$port（通过浏览器访问需关闭代理）正在运行，退出请输入Q/q"
    while :; do
        read -n 1 -s input
        if [ "$input" = "Q" ] || [ "$input" = "q" ]; then
            break
        fi
    done
    if [ "$server_pid" ]; then
        kill $server_pid
    fi
    if [ $ROOT -eq 0 ]; then
        if [ -e "$targetname" ]; then
            mv "$targetname" "$work_dir"
        fi
    fi
    cd ..
    rm -rf transfer_tmp
fi
