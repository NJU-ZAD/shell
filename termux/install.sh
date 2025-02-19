#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
MIRRORS="http://mirrors.aliyun.com/pypi/simple/"
HOST="mirrors.aliyun.com"
pkg install build-essential git vim make libllvm clang pkg-config gdb tracepath zip -y
pkg install python python-tkinter htop openssh expect zsh jq sshpass curl -y
zsh --version
apt-get autoremove -y
read -p "在安装zsh前必须GRACE！"
if [ -d "${HOME}/.oh-my-zsh" ]; then
    chmod +x ${HOME}/.oh-my-zsh/tools/uninstall.sh
    ${HOME}/.oh-my-zsh/tools/uninstall.sh
fi
rm -rf ${HOME}/.zshrc ${HOME}/.oh-my-zsh ${HOME}/.zsh_history ${HOME}/.zshrc.omz-uninstalled*
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
