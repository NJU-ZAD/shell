#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
if [ ! -f "wincorefonts.zip" ]; then
    echo "在shell/中没有找到wincorefonts.zip文件，将不会安装字体"
else
    sudo chmod -R 755 /usr/share/fonts
    echo "正在安装Windows系统目录C:\Windows\Fonts中的字体"
    sudo apt-get install unzip
    sudo apt-get install fontconfig
    if [ ! -d "wincorefonts/" ]; then
        unzip wincorefonts.zip
    fi
    if [ -d "/usr/share/fonts/truetype/wincorefonts/" ]; then
        sudo rm -rf /usr/share/fonts/truetype/wincorefonts/
    fi
    sudo mv wincorefonts/ /usr/share/fonts/truetype/
    sudo rm -rf ${HOME}/.cache/matplotlib
    echo "sudo fc-cache -fv"
    sudo fc-cache -fv
    echo "已经成功安装以下字体"
    ls /usr/share/fonts/truetype/wincorefonts/
fi
