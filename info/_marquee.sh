#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
input=$(head -n 1 "../data/marquee.txt")
rm -rf ../data/marquee.txt
blank="            "
color=8
sec=$(($RANDOM % 5 + 1))
str1="正在检查CPU运行状况..."
str2="正在评估内存读写..."
str3="正在检查网络适配器..."
str4="正在检查NVIDIA驱动..."
str5="正在检查CUDA版本..."
str6="正在检查DPDK版本..."
str7="正在检查文件系统..."
str8="正在检查其他外备..."
while :; do
    for ((i = 1; i <= $color; i++)); do
        output="$blank|$input"
        for ((r = 1; r <= $i; r++)); do
            if [ $r -le 4 ]; then
                output="$blank|$output"
            else
                output=$(echo "${output#*|}")
            fi
        done
        let j=i+29
        let k=77-j
        let l=i+39
        clear
        for ((m = 1; m <= $i * 20 / 8; m++)); do
            echo -e "\e[${l};${j};1m${output}\e[0m"
        done
        for ((n = 1; n <= 20; n++)); do
            echo -e "\e[${k};${j};1m${output}\e[0m"
        done
        for ((t = 1; t <= 40 - $i * 20 / 8; t++)); do
            echo -e "\e[${l};${j};1m${output}\e[0m"
        done
        str_=str${i}
        eval string=$(echo \$$str_)
        echo $string
        sleep $sec
    done
done
