#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
# 一个可能导致问题的典型操作
# sudo apt install python3.9 -y;sudo rm /usr/bin/python3;sudo ln -s /usr/bin/python3.9 /usr/bin/python3
# 使用CTRL+ALT+F4进入系统终端
read -p "该脚本旨在解决图形界面终端打不开或执行sudo apt update时遇到的ModuleNotFoundError问题"
python2=($(ls /usr/bin/python2.* 2>/dev/null | grep -v '\-config$' | sort -r -V))
user_python2=($(ls /usr/local/bin/python2.* 2>/dev/null | grep -v '\-config$' | sort -r -V))
python2=("${user_python2[@]}" "${python2[@]}")
if [ ${#python2[@]} -gt 0 ]; then
    index=1
    for version in "${python2[@]}"; do
        sudo update-alternatives --install /usr/bin/python2 python2 ${version} $index
        ((index++))
    done
    sudo update-alternatives --config python2 <<EOF
0
EOF
fi
python3=($(ls /usr/bin/python3.* 2>/dev/null | grep -v '\-config$' | sort -r -V))
user_python3=($(ls /usr/local/bin/python3.* 2>/dev/null | grep -v '\-config$' | sort -r -V))
python3=("${user_python3[@]}" "${python3[@]}")
if [ ${#python3[@]} -gt 0 ]; then
    index=1
    for version in "${python3[@]}"; do
        sudo update-alternatives --install /usr/bin/python3 python3 ${version} $index
        ((index++))
    done
    sudo update-alternatives --config python3 <<EOF
0
EOF
fi
echo
echo "若确实需要将高于系统自带版本（Ubuntu18.04一般为2.7和3.6，Ubuntu20.04一般为3.8）的Python设置为默认值考虑使用Conda虚拟环境实现类似效果"
curl --head --max-time 3 --silent --output /dev/null --fail "gitee.com"
if [ $? -eq 0 ]; then
    sudo apt update
    sudo apt upgrade
else
    echo "互联网连接存在问题"
fi
