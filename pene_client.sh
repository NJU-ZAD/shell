#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
source useful_func.sh
client_port=2222
curl --head --max-time 3 --silent --output /dev/null --fail "gitee.com"
if [ $? -ne 0 ]; then
    echo "互联网连接存在问题"
    exit
fi
find=$(dpkg -l | grep -w openssh-server)
if [ -z "$find" ]; then
    sudo apt-get install openssh-server -y
fi
find=$(dpkg -l | grep -w git)
if [ -z "$find" ]; then
    sudo apt-get install git -y
fi
find=$(dpkg -l | grep -w expect)
if [ -z "$find" ]; then
    sudo apt-get install expect -y
fi
find=$(dpkg -l | grep -w psmisc)
if [ -z "$find" ]; then
    sudo apt-get install psmisc -y
fi
if [ ! -d "${HOME}/penetration" ]; then
    echo "${HOME}下必须存在Gitee仓库penetration，其中包含两个空文件client.txt和server.txt"
    exit
fi
if [ ! -f "${HOME}/penetration/gitee.txt" ]; then
    echo "${HOME}/penetration/gitee.txt（第1、2、3行分别是Gitee邮箱、用户名、密码）不存在"
    exit
fi

ip=$(./get_ip.sh)
pid=$(pidof EasyConnect)
if [ -z "$pid" ]; then
    read -p "SSH服务器是否位于相同网段或通过路由器连接的子网中(Y/n)" -n 1 -s reply
    echo
else
    reply="N"
fi
if [ "$reply" == "N" ] || [ "$reply" == "n" ]; then
    if [ -z "$pid" ]; then
        if [ ! -f "/usr/share/sangfor/EasyConnect/EasyConnect" ]; then
            ~/shell/easyconnect.sh 1
        fi
        /usr/share/sangfor/EasyConnect/EasyConnect &
    fi
    while true; do
        if ifconfig tun0 &>/dev/null; then
            ip=$(./get_ip.sh tun0)
            break
        else
            sleep 1
        fi
    done
fi
sudo ufw allow $client_port
sshd=$(systemctl is-active ssh)
if [ "$sshd" == "inactive" ]; then
    sudo ufw allow ssh
    sudo service ssh start
fi

cd ${HOME}/penetration
client_path="client.txt"
server_path="server.txt"
git pull
>$client_path
echo ${USER} >>$client_path
echo ${ip} >>$client_path
Gitemail=$(sed -n 1p "gitee.txt")
Gituser=$(sed -n 2p "gitee.txt")
Gitpass=$(sed -n 3p "gitee.txt")
if [ -s "$server_path" ]; then
    sudo fuser -k $client_port/tcp
    >$server_path
    git_push "$client_path $server_path" "上传客户端地址并初始化隧道状态" $Gitemail $Gituser $Gitpass
else
    git_push "$client_path" "客户端地址已经上传" $Gitemail $Gituser $Gitpass
fi
while true; do
    if nc -z localhost $client_port; then
        break
    else
        sleep 1
    fi
done
read -p "输入远程SSH服务器的用户名：" USERNAME
echo "接下来输入SSH服务器的密码："
ssh ${USERNAME}@localhost -p $client_port
