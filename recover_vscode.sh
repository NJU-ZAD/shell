#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
currdir=$(
    cd $(dirname $0)
    pwd
)

if [ ! -f "vscode.zip" ]; then
    echo "在shell/中没有找到备份文件vscode.zip！"
    echo "通过shell/backup_vscode.sh可以创建备份文件！"
else
    echo -e "\e[31m确保vscode是最新版\e[0m"
    read -p "按回车键继续..."
    sudo apt-get install unzip
    sudo apt-get install fontconfig
    if [ ! -d "vscode/" ]; then
        unzip vscode.zip
    fi
    if [ ! -d "${HOME}/.local/share/fonts/" ]; then
        sudo mkdir ${HOME}/.local/share/fonts/
    fi
    sudo \cp vscode/TTF/FiraCode-Bold.ttf ${HOME}/.local/share/fonts/FiraCode-Bold.ttf
    sudo \cp vscode/TTF/FiraCode-Light.ttf ${HOME}/.local/share/fonts/FiraCode-Light.ttf
    sudo \cp vscode/TTF/FiraCode-Medium.ttf ${HOME}/.local/share/fonts/FiraCode-Medium.ttf
    sudo \cp vscode/TTF/FiraCode-Regular.ttf ${HOME}/.local/share/fonts/FiraCode-Regular.ttf
    sudo \cp vscode/TTF/FiraCode-Retina.ttf ${HOME}/.local/share/fonts/FiraCode-Retina.ttf
    echo "fc-cache -f"
    fc-cache -f
    if [ ! -d "${HOME}/.vscode/" ]; then
        sudo mkdir ${HOME}/.vscode/
    fi
    sudo chown ${USER}: -R ${HOME}/.vscode/
    sudo \cp vscode/argv.json ${HOME}/.vscode/argv.json
    echo "creating extensions"
    if [ -d "${HOME}/.vscode/extensions" ]; then
        sudo rm -rf ${HOME}/.vscode/extensions
    fi
    sudo \cp -r vscode/extensions ${HOME}/.vscode/
    echo "creating settings.json"
    if [ ! -d "${HOME}/.config/Code/" ]; then
        sudo mkdir ${HOME}/.config/Code/
    fi
    if [ ! -d "${HOME}/.config/Code/User/" ]; then
        sudo mkdir ${HOME}/.config/Code/User/
    fi
    sudo cp -r vscode/settings.json ${HOME}/.config/Code/User/settings.json
    sudo chown ${USER}: -R ${HOME}/.vscode/
    sudo chown ${USER}: -R ${HOME}/.config/
    cd $currdir
    sudo rm -rf vscode/
    echo
    echo "已经成功恢复vscode的设置、字体、扩展等！"
    # echo
    # echo "安装Python和Pylance扩展后可能出现右键菜单误点问题"
    # echo "sudo apt-get install easystroke -y"
    # echo "打开Easystroke鼠标手势辨认->偏好设置->手势按钮->右击灰色矩形区域"
    # echo "超时档案->超时关闭"
fi
