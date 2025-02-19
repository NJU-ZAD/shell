#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
ver=952
_v=9.5
_ver=$_v.2
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ "$1" = "1" ] || [ "$1" = "2" ]; then
        error=0
        echo "安装Gurobi $_ver..."
        gurobi=gurobi${_ver}_linux64.tar.gz
        address=$_v/$gurobi
        if [ ! -f "./$gurobi" ]; then
            echo "正在从网络获取$gurobi"
            if [ "$1" = "1" ]; then
                curl -L -O https://packages.gurobi.com/$address
            elif [ "$1" = "2" ]; then
                sudo apt install tsocks -y
                touch tsocks.conf
                cat >tsocks.conf <<END_TEXT
server = 127.0.0.1
server_type = 5
server_port = 1080
END_TEXT
                sudo mv tsocks.conf /etc/tsocks.conf
                tsocks curl -L -O https://packages.gurobi.com/$address
            fi
        else
            echo "已经获取本地$gurobi"
        fi
        sudo apt-get install python3 python3-pip -y
        tar -xf $gurobi
        sudo rm -rf /opt/gurobi$ver
        sudo mv gurobi$ver /opt/
        cd /opt/gurobi$ver/linux64
        sudo python3 setup.py install
        shell=$(env | grep SHELL=)
        echo $shell
        if [ $shell = "SHELL=/bin/bash" ]; then
            rc=.bashrc
        else
            rc=.zshrc
        fi
        echo "为用户${USER}配置gurobipy的环境变量..."
        if [ $(grep -c "export GUROBI_HOME=\"/opt/gurobi$ver/linux64\"" ${HOME}/$rc) -eq 0 ]; then
            echo "export GUROBI_HOME=\"/opt/gurobi$ver/linux64\"" >>${HOME}/$rc
        fi
        if [ $(grep -c "export PATH=\"\${PATH}:\${GUROBI_HOME}/bin\"" ${HOME}/$rc) -eq 0 ]; then
            echo "export PATH=\"\${PATH}:\${GUROBI_HOME}/bin\"" >>${HOME}/$rc
        fi
        if [ $(grep -c "export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:\${GUROBI_HOME}/lib\"" ${HOME}/$rc) -eq 0 ]; then
            echo "export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:\${GUROBI_HOME}/lib\"" >>${HOME}/$rc
        fi
        # gedit ${HOME}/.bashrc
        # gedit ${HOME}/.zshrc
        if [ $shell = "SHELL=/bin/bash" ]; then
            gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
        else
            gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
        fi
        sudo ldconfig
        echo
        echo -e "\e[32m必须在新的终端中使用gurobi！\e[0m"
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载Gurobi $_ver..."
        sudo rm -rf /opt/gurobi$ver
        # pip3 show gurobipy
        # read -p "通过cd转到gurobipy的pip目录并运行sudo rm -rf gurobipy gurobipy-${_ver}.egg-info后继续"
        cd /usr/local/lib/python3*/dist-packages
        sudo rm -rf gurobipy gurobipy-${_ver}.egg-info
        shell=$(env | grep SHELL=)
        if [ $shell = "SHELL=/bin/bash" ]; then
            rc=.bashrc
        else
            rc=.zshrc
        fi
        sed -i "/GUROBI_HOME/d" ${HOME}/$rc
        if [ $shell = "SHELL=/bin/bash" ]; then
            gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
        else
            gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
        fi
        sudo ldconfig
    elif [ $1 = "h" ]; then
        error=0
        echo "登录Gurobi"
        echo "https://www.gurobi.com/"
        echo "获取Gurobi"
        echo "https://www.gurobi.com/downloads/gurobi-software/"
        echo "获取激活码"
        echo "https://www.gurobi.com/downloads/free-academic-license/"
        echo "管理激活码"
        echo "https://www.gurobi.com/downloads/licenses/"
        echo
        echo "执行 grbgetkey [激活码]"
        echo
        if [ -f "${HOME}/gurobi.lic" ]; then
            /opt/gurobi$ver/linux64/examples/python/bilinear.py
            echo -e "\e[32m已经成功安装并激活Gurobi！\e[0m"
        fi
    fi
fi
if [ $error = "1" ]; then
    echo "./gurobi.sh 1	安装gurobi"
    echo "./gurobi.sh 2	安装gurobi（socks5代理）"
    echo "./gurobi.sh 0	卸载gurobi"
    echo "./gurobi.sh h	关于gurobi"
fi
