#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
if [ -n "$1" ]; then
    if [ "$1" = "1" ]; then
        error=0
        echo "在指定目录下创建多个文件（按照一定规律）"
        echo "主目录为"${HOME}
        read -p "输入指定目录：" dir
        if [ ! -d "$dir" ]; then
            echo -e "指定目录\e[32m$dir\e[0m不存在！"
            exit
        fi
        if [ "$dir" = "/" ] || [ "$dir" = "${HOME}" ]; then
            echo -e "\e[31m为了安全起见原则上不允许指定根目录或主目录！\e[0m"
            exit
        fi
        read -p "输入文件名的常量部分：" filename
        read -p "输入文件名的变量部分的最小值：" min
        read -p "输入文件名的变量部分的最大值：" max
        read -p "输入文件的扩展名（*）：" ext
        for ((i = $min; i <= $max; i++)); do
            sudo touch $dir/$filename$i.$ext
        done
        sudo chown ${USER}: -R $dir
    elif [ "$1" = "2" ]; then
        error=0
        echo "在指定目录下创建多个目录（按照一定规律）"
        echo "主目录为"${HOME}
        read -p "输入指定目录：" dir
        if [ ! -d "$dir" ]; then
            echo -e "指定目录\e[32m$dir\e[0m不存在！"
            exit
        fi
        if [ "$dir" = "/" ] || [ "$dir" = "${HOME}" ]; then
            echo -e "\e[31m为了安全起见原则上不允许指定根目录或主目录！\e[0m"
            exit
        fi
        read -p "输入目录名的常量部分：" dirname
        read -p "输入目录名的变量部分的最小值：" min
        read -p "输入目录名的变量部分的最大值：" max
        for ((i = $min; i <= $max; i++)); do
            sudo mkdir $dir/$dirname$i
        done
        sudo chown ${USER}: -R $dir
    fi
fi
if [ $error -eq 1 ]; then
    echo "./create_file.sh 1 在指定目录下创建多个文件（按照一定规律）"
    echo "./create_file.sh 2 在指定目录下创建多个目录（按照一定规律）"
fi
