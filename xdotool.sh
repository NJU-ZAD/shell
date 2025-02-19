#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
sudo apt-get install xdotool -y
echo "xdotool version"
xdotool version
echo
echo "鼠标操作：获取光标位置"
echo "xdotool getmouselocation"
echo "鼠标操作：移动到(250,500）"
echo "xdotool mousemove 250 500"
echo "鼠标操作：左键"
echo "xdotool click 1"
echo "鼠标操作：右键"
echo "xdotool click 3"
echo "键盘操作：delete"
echo "xdotool key Delete"
echo "键盘操作：ctrl+alt+t"
echo "xdotool key ctrl+alt+t"
