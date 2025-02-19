#!/bin/ash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
sed -i 's#apk.ish.app/v3.14-2023-05-19#mirrors.tuna.tsinghua.edu.cn/alpine/v3.14#g' /etc/apk/repositories
apk add git bash vim net-tools htop zip curl zsh zsh-vcs expect openssh libuser jq
zsh --version
read -p "在安装zsh前必须GRACE！"
if [ -d "${HOME}/.oh-my-zsh" ]; then
    chmod +x ${HOME}/.oh-my-zsh/tools/uninstall.sh
    ${HOME}/.oh-my-zsh/tools/uninstall.sh
fi
rm -rf ${HOME}/.zshrc ${HOME}/.oh-my-zsh ${HOME}/.zsh_history ${HOME}/.zshrc.omz-uninstalled*
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
