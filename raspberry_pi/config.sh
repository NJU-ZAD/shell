#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo "修改pi的密码"
sudo passwd pi
echo "修改root的密码"
sudo passwd root
lsb_release -a
uname -a
echo "正在利用南大源更新sources.list和raspi.list..."
if [ ! -d "/etc/apt/sources_backup" ]; then
    sudo mkdir /etc/apt/sources_backup
    sudo mv /etc/apt/sources.list /etc/apt/sources_backup
    echo "已经将原始sources.list备份至/etc/apt/sources_backup"
fi
if [ ! -d "/etc/apt/raspi_backup" ]; then
    sudo mkdir /etc/apt/raspi_backup
    sudo mv /etc/apt/sources.list.d/raspi.list /etc/apt/raspi_backup
    echo "已经将原始raspi.list备份至/etc/apt/raspi_backup"
fi
release_num=$(lsb_release -r --short)
case "$release_num" in
"9")
    VERSION=stretch
    ;;
"10")
    VERSION=buster
    ;;
"11")
    VERSION=bullseye
    ;;
*)
    exit
    ;;
esac
touch ${HOME}/sources.list
cat >${HOME}/sources.list <<END_TEXT
deb https://mirrors.nju.edu.cn/debian/ ${VERSION} main contrib non-free
deb https://mirrors.nju.edu.cn/debian/ ${VERSION}-proposed-updates main contrib non-free
deb https://mirrors.nju.edu.cn/debian/ ${VERSION}-updates main contrib non-free
deb-src https://mirrors.nju.edu.cn/debian/ ${VERSION} main contrib non-free
deb-src https://mirrors.nju.edu.cn/debian/ ${VERSION}-proposed-updates main contrib non-free
deb-src https://mirrors.nju.edu.cn/debian/ ${VERSION}-updates main contrib non-free
END_TEXT
touch ${HOME}/raspi.list
cat >${HOME}/raspi.list <<END_TEXT
deb https://mirrors.nju.edu.cn/raspberrypi/debian/ ${VERSION} main
deb-src https://mirrors.nju.edu.cn/raspberrypi/debian/ ${VERSION} main
END_TEXT
if [ -f "/etc/apt/sources.list" ]; then
    sudo rm -rf /etc/apt/sources.list
fi
sudo mv ${HOME}/sources.list /etc/apt/sources.list
if [ -f "/etc/apt/sources.list.d/raspi.list" ]; then
    sudo rm -rf /etc/apt/sources.list.d/raspi.list
fi
sudo mv ${HOME}/raspi.list /etc/apt/sources.list.d/raspi.list
sudo apt-get update -y
sudo apt-get upgrade -y
if [ -f "${HOME}/.zshrc" ]; then
    # sed -i "s#ZSH_THEME=\"robbyrussell\"#ZSH_THEME=\"agnoster\"#g" ${HOME}/.zshrc
    sed -i "s#ZSH_THEME=\"robbyrussell\"#ZSH_THEME=\"ys\"#g" ${HOME}/.zshrc
    echo "已更改终端样式，请重新启动终端"
    echo "omz update"
fi
echo
echo "可以通过chsh -s /bin/bash更改为默认终端bash"
