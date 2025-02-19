#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
if [ ! -f "../private-shell/data/sshfs.txt" ]; then
    echo "../private-shell/data/sshfs.txt不存在！"
    echo "../private-shell/data/sshfs.txt第1行为server_user"
    echo "../private-shell/data/sshfs.txt第2行为server_IP"
    echo "../private-shell/data/sshfs.txt第3行为server_port"
    echo "../private-shell/data/sshfs.txt第4行为server_dir"
    exit
fi
server_user=$(sed -n 1p "../private-shell/data/sshfs.txt")
server_IP=$(sed -n 2p "../private-shell/data/sshfs.txt")
server_port=$(sed -n 3p "../private-shell/data/sshfs.txt")
server_dir=$(sed -n 4p "../private-shell/data/sshfs.txt")
specify_port=22
specify_dir=share
error=1
if [ -n "$1" ] && [ -n "$2" ]; then
    if [ $1 = "s" ] || [ $1 = "S" ]; then
        if [ $2 = "1" ]; then
            error=0
            echo -e "\e[34m以服务器端启动：\e[0m"
            echo -e "\e[31m[1]确保与客户端同处一个有效的局域网下（如手机的热点网络）\e[0m"
            echo -e "\e[31m[2]若在虚拟机中需要修改网络为桥接模式\e[0m"
            echo -e "\e[31m[3]确保已运行./sshfs.sh\e[0m"
            read -p "若条件满足请按回车键继续..."
            sudo ufw allow ssh
            sudo service ssh start
            while :; do
                ifconfig
                read -p "输入服务器网卡名：" server_NIC
                inet=$(ifconfig | grep -A 1 "$server_NIC")
                OLD_IFS="$IFS"
                IFS=" "
                inets=($inet)
                IFS="$OLD_IFS"
                let "i=0"
                for var in ${inets[@]}; do
                    if [ $var = "inet" ]; then
                        break
                    fi
                    let "i=i+1"
                done
                let "i=i+1"
                server_IP=${inets[$i]}
                server_IP=$(echo "$server_IP" | sed 's/ //g')
                if [ "$server_IP" != "" ]; then
                    break
                else
                    echo -e "\e[31m服务器网卡名错误！\e[0m"
                fi
            done
            echo "服务器端的IPv4地址是"$server_IP
            echo "$USER" >../private-shell/data/sshfs.txt
            echo "$server_IP" >>../private-shell/data/sshfs.txt
            echo "$specify_port" >>../private-shell/data/sshfs.txt
            echo "$specify_dir" >>../private-shell/data/sshfs.txt
            cd ../private-shell
            ./git_push.sh
            if [ ! -d "${HOME}/$specify_dir" ]; then
                mkdir ${HOME}/$specify_dir
            fi
        elif [ $2 = "0" ]; then
            error=0
            echo -e "\e[34m服务器端停止\e[0m"
            sudo service ssh stop
            ps -e | grep ssh
        fi
    elif [ $1 = "c" ] || [ $1 = "C" ]; then
        if [ $2 = "1" ]; then
            error=0
            echo -e "\e[34m以客户端启动：\e[0m"
            echo -e "\e[31m[1]确保与服务器端同处一个有效的局域网下（如手机的热点网络）\e[0m"
            echo -e "\e[31m[2]若在虚拟机中需要修改网络为桥接模式\e[0m"
            read -p "若条件满足请按回车键继续..."
            if [ ! -d "${HOME}/$server_dir" ]; then
                mkdir ${HOME}/$server_dir
            fi
            echo "ping -c 1 $server_IP"
            ping -c 1 $server_IP
            echo -e "\e[34m若无法ping通服务器说明该局域网存在问题\e[0m"
            sshfs $server_user@$server_IP:/home/$server_user/$server_dir ${HOME}/$server_dir -p $server_port
        elif [ $2 = "2" ]; then
            error=0
            echo -e "\e[34m以客户端启动（NAT）：\e[0m"
            server_IP=$(sed -n 1p "${HOME}/private-shell/data/sakurafrp.txt")
            server_port=$(sed -n 2p "${HOME}/private-shell/data/sakurafrp.txt")
            if [ ! -d "${HOME}/$server_dir" ]; then
                mkdir ${HOME}/$server_dir
            fi
            echo "ping -c 1 $server_IP"
            ping -c 1 $server_IP
            sshfs $server_user@$server_IP:/home/$server_user/$server_dir ${HOME}/$server_dir -p $server_port
        elif [ $2 = "0" ]; then
            error=0
            echo -e "\e[34m客户端停止\e[0m"
            sudo umount -f ${HOME}/$server_dir
            sudo rm -rf ${HOME}/$server_dir
        fi
    fi
elif [ ! -n "$1" ] && [ ! -n "$2" ]; then
    error=0
    sudo apt-get install openssh-client -y
    sudo apt-get install openssh-server -y
    sudo apt-get install sshfs -y
fi
if [ $error = "1" ]; then
    echo "./sshfs.sh	安装必备软件包"
    echo "./sshfs.sh s 1	作为服务器端启动"
    echo "./sshfs.sh s 0	服务器端停止"
    echo "./sshfs.sh c 1	作为客户端启动"
    echo "./sshfs.sh c 2	作为客户端启动（NAT）"
    echo "./sshfs.sh c 0	客户端停止"
fi
