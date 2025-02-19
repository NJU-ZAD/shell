#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
read -p "输入字符串：" input
if [ -f "../data/marquee.txt" ]; then
    touch ../data/marquee.txt
fi
echo "$input" >../data/marquee.txt
shell=$(env | grep SHELL=)
if [ $shell = "SHELL=/bin/bash" ]; then
    gnome-terminal --full-screen -- /bin/sh -c ./_marquee.sh
else
    gnome-terminal --full-screen -- /bin/zsh -c ./_marquee.sh
fi
