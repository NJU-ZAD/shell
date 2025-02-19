#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
currdir=$(pwd)
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
if [ -f "$PREFIX/etc/apt/sources.list.d/game.list" ]; then
    sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
fi
if [ -f "$PREFIX/etc/apt/sources.list.d/science.list" ]; then
    sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
fi
apt update && apt upgrade -y
termux-setup-storage
if [ -f "${HOME}/.zshrc" ]; then
    powerlevel10k_dir=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    if [ ! -d "$powerlevel10k_dir" ]; then
        git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git $powerlevel10k_dir
    else
        cd $powerlevel10k_dir
        git pull
        cd $currdir
    fi
    sed -i "s#ZSH_THEME=\"robbyrussell\"#ZSH_THEME=\"powerlevel10k/powerlevel10k\"#g" ~/.zshrc
    if ! grep -q 'p10k.zsh' ${HOME}/.zshrc; then
        echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >>${HOME}/.zshrc
    fi
    rm -rf ${HOME}/.p10k.zsh
    cp .p10k.zsh ${HOME}/.p10k.zsh
    echo "请重新启动终端后运行p10k configure来安装MesloLGS NF字体（需要GRACE）"
fi
