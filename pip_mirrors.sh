#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input

mkdir -p ${HOME}/.pip
pip_conf=${HOME}/.pip/pip.conf
rm -rf ${pip_conf}
touch ${pip_conf}

find=$(dpkg -l | grep -w curl)
if [ -z "$find" ]; then
    sudo apt-get install curl -y
fi

url1=https://mirrors.nju.edu.cn/pypi/web/simple/
url2=https://pypi.tuna.tsinghua.edu.cn/simple/
url3=https://mirrors.aliyun.com/pypi/simple/
url4=https://pypi.mirrors.ustc.edu.cn/simple/

read -p "是否测试国内源的下载速度？Y/n：" -n 1 answer
echo
if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
    curl -o /dev/null -s -w "1. 南京大学 "%{speed_download}"\n" "$url1"
    curl -o /dev/null -s -w "2. 清华大学 "%{speed_download}"\n" "$url2"
    curl -o /dev/null -s -w "3. 阿里云 "%{speed_download}"\n" "$url3"
    curl -o /dev/null -s -w "4. 中国科学技术大学 "%{speed_download}"\n" "$url4"
else
    echo "1. 南京大学"
    echo "2. 清华大学"
    echo "3. 阿里云"
    echo "4. 中国科学技术大学"
fi

read -p "输入数字选择（1/2/3/4）：" -n 1 choice
echo
case $choice in
1)
    echo "[global]" >${pip_conf}
    echo "index-url = $url1" >>${pip_conf}
    ;;
2)
    echo "[global]" >${pip_conf}
    echo "index-url = $url2" >>${pip_conf}
    ;;
3)
    echo "[global]" >${pip_conf}
    echo "index-url = $url3" >>${pip_conf}
    ;;
4)
    echo "[global]" >${pip_conf}
    echo "index-url = $url4" >>${pip_conf}
    ;;
*)
    echo "输入错误，未更改pip源"
    ;;
esac
