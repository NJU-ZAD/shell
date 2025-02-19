#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
MIRRORS="http://mirrors.aliyun.com/pypi/simple/"
HOST="mirrors.aliyun.com"
if [ ! -n "$1" ]; then
    error=0
    sudo apt-get install python3 python3-dev python3-venv python3-pip cm-super dvipng -y
    pip3 install --upgrade pip numpy matplotlib scipy autopep8 pep8 pycodestyle xlrd==1.2.0 xlwt scipy scikit-learn \
        -i $MIRRORS --trusted-host $HOST

elif [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        export all_proxy=""
        pip3 install --upgrade pysocks -i $MIRRORS --trusted-host $HOST
        export all_proxy="socks5://127.0.0.1:1080"
        sudo apt-get install python3 python3-dev python3-venv python3-pip cm-super dvipng -y
        pip3 install --upgrade pip numpy matplotlib scipy autopep8 pep8 pycodestyle xlrd==1.2.0 xlwt scipy scikit-learn \
            -i $MIRRORS --trusted-host $HOST
    fi
fi
if [ $error = "1" ]; then
    echo "python2代码开头一般添加"
    echo "#!/usr/bin/python"
    echo "# -*- coding:utf-8 -*-"
    echo "python3代码开头一般添加"
    echo "#!/usr/bin/python3"
    echo "# -*- coding:utf-8 -*-"
    echo "main函数"
    echo "if __name__='__main__':"
    echo
    echo "./python.sh	更新python相关软件包"
    echo "./python.sh 1	更新python相关软件包（socks5代理）"
fi
