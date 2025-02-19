#!/bin/ash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
if [ ! -f "${HOME}/.zshrc" ]; then
    sed -i 's#apk.ish.app/v3.14-2023-05-19#mirrors.tuna.tsinghua.edu.cn/alpine/v3.14#g' /etc/apk/repositories
    apk update
    ping localhost -c 3
    echo "为root用户设置新的密码"
    passwd
else
    if [ ! -f "/etc/login.defs" ]; then
        touch /etc/login.defs
    fi
    if [ ! -d "/etc/default" ]; then
        mkdir /etc/default
    fi
    if [ ! -f "/etc/default/useradd" ]; then
        touch /etc/default/useradd
    fi
    read -p "接下来输入新的终端/bin/zsh"
    lchsh ${USER}
    sed -i "s#ZSH_THEME=\"robbyrussell\"#ZSH_THEME=\"agnoster\"#g" ${HOME}/.zshrc
    echo "已更改终端样式，请重新启动终端"
    echo "omz update"
    echo "按照以下步骤来配置终端字体"
    echo "1.在iPad/iPhone中安装iFont软件来安装MesloLGS NF字体家族"
    echo "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    echo "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
    echo "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
    echo "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
    echo "2.[iSH] Settings->Appearance->Font->MesloLGS NF"
fi
