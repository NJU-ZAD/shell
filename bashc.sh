#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
exe=fix_server
script=${HOME}/private-shell/$exe.sh
if [ ! -f "/usr/bin/_bashc" ]; then
    find=$(dpkg -l | grep -w wget)
    if [ -z "$find" ]; then
        sudo apt-get install wget -y
    fi
    version=5.2.15
    # https://github.com/ajdiaz/bashc/releases
    curl -L https://github.com/ajdiaz/bashc/releases/download/$version/bashc --output _bashc
    chmod +x _bashc
    sudo mv _bashc /usr/bin/_bashc
    sudo chown root: /usr/bin/_bashc
    shell=$(env | grep SHELL=)
    echo $shell
    if [ $shell = "SHELL=/bin/bash" ]; then
        rc=.bashrc
    else
        rc=.zshrc
    fi
    sed -i "/bashc/d" ${HOME}/$rc
    echo "bashc() {/usr/bin/_bashc \"\$@\"}" >>${HOME}/$rc
    # sudo rm -rf /usr/bin/_bashc
fi
echo "执行 source ${HOME}/$rc;bashc $script $exe 来打包脚本"
echo "cp $exe ${HOME}/crucio/network_pipeline/$exe;cp $exe ${HOME}/icoder/network_pipeline/$exe;cp $exe ${HOME}/mesh/networking/$exe"
