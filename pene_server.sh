#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
source useful_func.sh
client_port=2222
echo "本机IP地址为"$(./get_ip.sh)
curl --head --max-time 3 --silent --output /dev/null --fail "gitee.com"
if [ $? -ne 0 ]; then
    echo "互联网连接存在问题"
    exit
fi
find=$(dpkg -l | grep -w openssh-server)
if [ -z "$find" ]; then
    sudo apt-get install openssh-server -y
fi
find=$(dpkg -l | grep -w sshpass)
if [ -z "$find" ]; then
    sudo apt-get install sshpass -y
fi
find=$(dpkg -l | grep -w git)
if [ -z "$find" ]; then
    sudo apt-get install git -y
fi
find=$(dpkg -l | grep -w expect)
if [ -z "$find" ]; then
    sudo apt-get install expect -y
fi
if [ ! -d "${HOME}/penetration" ]; then
    echo "${HOME}下必须存在Gitee仓库penetration，其中包含两个空文件client.txt和server.txt"
    exit
fi
if [ ! -f "${HOME}/penetration/gitee.txt" ]; then
    echo "${HOME}/penetration/gitee.txt（第1、2、3行分别是Gitee邮箱、用户名、密码）不存在"
    exit
fi

sshd=$(systemctl is-active ssh)
if [ "$sshd" == "inactive" ]; then
    sudo ufw allow ssh
    sudo service ssh start
fi
sshconfig="${HOME}/.ssh"
if [ ! -d "$sshconfig" ]; then
    mkdir "$sshconfig"
fi
known_hosts="$sshconfig/known_hosts"
if [ ! -f "$known_hosts" ]; then
    touch "$known_hosts"
fi

create_reverse_tunnel() {
    local USERNAME="$1"
    local HOST="$2"
    local attempt=0
    local max_attempts=4
    local timeout=5
    failure=0
    is_known=$(grep "$HOST" $known_hosts)
    if [ -z "$is_known" ]; then
        ssh-keyscan -t rsa $HOST >>$known_hosts
    fi
    Rtunnel_pid=$(pgrep -u ${USER} -f 'ssh -R')
    if [ "$Rtunnel_pid" ]; then
        kill $Rtunnel_pid
    fi
    while [[ $attempt -lt $max_attempts ]]; do
        sshpass -p $PASSWORD ssh -R $client_port:localhost:22 -o ConnectTimeout=$timeout -q -C -N -f $USERNAME@$HOST
        status=$?
        while true; do
            if [ $status -ne 0 ]; then
                break
            fi
            if nc -z ${HOST} 22; then
                echo "SSH隧道正在运行"
                sleep $timeout
            else
                Rtunnel_pid=$(pgrep -u ${USER} -f 'ssh -R')
                if [ "$Rtunnel_pid" ]; then
                    kill $Rtunnel_pid
                fi
                echo "当前SSH隧道已经失效"
                failure=1
                break
            fi
        done
        ((attempt++))
    done
    echo $failure
}

cd ${HOME}/penetration
client_path="client.txt"
server_path="server.txt"
Gitemail=$(sed -n 1p "gitee.txt")
Gituser=$(sed -n 2p "gitee.txt")
Gitpass=$(sed -n 3p "gitee.txt")
git pull
if [ -s "$client_path" ]; then
    >$client_path
fi
if [ -s "$server_path" ]; then
    >$server_path
fi
git_push "$server_path $client_path" "Pene初始化" $Gitemail $Gituser $Gitpass

wait_time=15
read -s -p "输入拟连接到本机SSH服务器的客户端密码：" PASSWORD
echo
HOST_SET=()
while true; do
    git pull
    if [ -s "$client_path" ]; then
        USERNAME=$(sed -n '1p' "$client_path")
        HOST=$(sed -n '2p' "$client_path")
        HOST_SET+=($HOST)
        failure=$(create_reverse_tunnel $USERNAME $HOST)
        >$client_path
        if [ "$failure" == "0" ]; then
            git_push "$client_path" "客户端已经断开SSH连接" $Gitemail $Gituser $Gitpass
        else
            echo "1" >$server_path
            git_push "$server_path $client_path" "服务器遇到隧道失效问题" $Gitemail $Gituser $Gitpass
        fi
    fi
    read -p "要退出Pene Server请输入Q/q" -t $wait_time -n 1 -s input
    echo
    if [ "$input" = "Q" ] || [ "$input" = "q" ]; then
        break
    fi
done
for item in "${HOST_SET[@]}"; do
    echo "从SSH配置中去除"$item
    ssh-keygen -R $item
done
