#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
# https://go.dev/dl/
error=1
version=1.21.0
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        echo "安装Go..."
        name=go${version}.linux-amd64.tar.gz
        if [ ! -f "./${name}" ]; then
            echo "正在从网络获取${name}"
            curl -L -O https://dl.google.com/go/${name}
        else
            echo "已经获取本地${name}"
        fi
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "${name}"
        shell=$(env | grep SHELL=)
        echo $shell
        if [ $shell = "SHELL=/bin/bash" ]; then
            rc=.bashrc
        else
            rc=.zshrc
        fi
        if [ $(grep -c "export PATH=\"/usr/local/go/bin:\$PATH\"" ${HOME}/$rc) -eq 0 ]; then
            echo "export PATH=\"/usr/local/go/bin:\$PATH\"" >>${HOME}/$rc
        fi
        # gedit ${HOME}/.bashrc
        # gedit ${HOME}/.zshrc
        if [ $shell = "SHELL=/bin/bash" ]; then
            gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
        else
            gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
        fi
        echo "必须在新的终端中使用go version！"
    elif [ $1 = "+" ]; then
        error=0
        echo "配置Go..."
        if [ ! -f "go.zip" ]; then
            echo "在shell/中没有找到go.zip"
            exit
        fi
        if [ -d "${HOME}/go" ]; then
            sudo rm -rf ${HOME}/go
        fi
        unzip -q 'go.zip'
        mv go ${HOME}/go
    elif [ $1 = "2" ]; then
        error=0
        echo "更新Go配置（需要代理）..."
        array=(
            "github.com/cweill/gotests/gotests"
            "github.com/fatih/gomodifytags"
            "github.com/josharian/impl"
            "github.com/go-delve/delve/cmd/dlv"
            "honnef.co/go/tools/cmd/staticcheck"
            "golang.org/x/tools/gopls"
            "github.com/ramya-rao-a/go-outline"
        )
        let i=0
        for name in "${array[@]}"; do
            let i=i+1
            echo ${i}----${name}
            /usr/local/go/bin/go install -v ${name}@latest
        done
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载Go..."
        sudo rm -rf /usr/local/go
        shell=$(env | grep SHELL=)
        echo $shell
        if [ $shell = "SHELL=/bin/bash" ]; then
            rc=.bashrc
        else
            rc=.zshrc
        fi
        sed -i "/go/d" ${HOME}/$rc
        if [ $shell = "SHELL=/bin/bash" ]; then
            gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
        else
            gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
        fi
    fi
fi
if [ $error = "1" ]; then
    echo "./go.sh 1	安装Go"
    echo "./go.sh +	配置Go"
    echo "./go.sh 2	更新Go配置（需要代理）"
    echo "./go.sh 0	卸载Go"
fi
