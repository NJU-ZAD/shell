#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo "在指定目录下的所有文件或目录的名称中数字前补0"
echo "主目录为"${HOME}
read -p "输入指定目录：" spec_dir
if [ ! -d "$spec_dir" ]; then
    echo -e "指定目录\e[32m$spec_dir\e[0m不存在！"
    exit
fi
if [ "$spec_dir" = "/" ] || [ "$spec_dir" = "${HOME}" ]; then
    echo -e "\e[31m为了安全起见原则上不允许指定根目录或主目录！\e[0m"
    exit
fi
read -p "输入补0后的位数：" zero_bits
for file in $(ls $spec_dir); do
    # echo $file
    number=$(echo $file | tr -cd "[0-9]")
    ext_number=$(printf "%0${zero_bits}d" $number)
    new_file=${file/$number/$ext_number}
    # echo $new_file
    mv $spec_dir/$file $spec_dir/$new_file
    echo "已将 \"$file\" 重命名为 \"$new_file\""
done
