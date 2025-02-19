#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
sudo apt-get install vim git htop net-tools python3 python3-pip \
    gcc expect screen openssh-client openssh-server zsh unzip -y
sudo apt-get autoremove -y

specify_port=22
sudo service ssh start
ps -e | grep ssh
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
echo "$USER" >../../private-shell/data/ssh.txt
echo "$server_IP" >>../../private-shell/data/ssh.txt
echo "$specify_port" >>../../private-shell/data/ssh.txt
cd ../../private-shell
./git_push.sh
echo
echo -e "\e[32m确保ssh服务开机自启\e[0m"
echo "在Raspberry Pi终端中输入sudo raspi-config"
echo "Interfacing Options->SSH->Yes"
echo
read -p "接下来将安装zsh！"
echo -e "\e[32m安装完成后务必重启Raspberry Pi\e[0m"
zsh --version
# git clone https://github.com/ohmyzsh/ohmyzsh.git
if [ -d "${HOME}/.oh-my-zsh" ]; then
    chmod +x ${HOME}/.oh-my-zsh/tools/uninstall.sh
    ${HOME}/.oh-my-zsh/tools/uninstall.sh
fi
rm -rf ${HOME}/.zshrc ${HOME}/.oh-my-zsh ${HOME}/.zsh_history ${HOME}/.zshrc.omz-uninstalled*
cd ${HOME}/shell/ish
unzip ohmyzsh.zip
mv ohmyzsh ${HOME}/.oh-my-zsh
../_zsh_install.sh
