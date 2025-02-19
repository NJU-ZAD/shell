#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
# https://docs.docker.com/engine/install/ubuntu/
error=1
currdir=$(pwd)
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        release_num=$(lsb_release -r --short)
        case "$release_num" in
        "22.04")
            ubuntu_v=jammy
            ce_v=20.10.17~3-0
            ;;
        "21.10")
            ubuntu_v=impish
            ce_v=20.10.17~3-0
            ;;
        "20.04")
            ubuntu_v=focal
            ce_v=20.10.9~3-0
            ;;
        "18.04")
            ubuntu_v=bionic
            ce_v=20.10.9~3-0
            ;;
        *)
            echo "不支持的系统版本"
            exit
            ;;
        esac
        containerd_io=containerd.io_1.6.8-1_amd64.deb
        docker_ce_cli=docker-ce-cli_${ce_v}~ubuntu-${ubuntu_v}_amd64.deb
        docker_ce=docker-ce_${ce_v}~ubuntu-${ubuntu_v}_amd64.deb
        docker_compose_plugin=docker-compose-plugin_2.6.0~ubuntu-${ubuntu_v}_amd64.deb
        URL=https://download.docker.com/linux/ubuntu/dists/$ubuntu_v/pool/stable/amd64

        if [ ! -f "./$containerd_io" ]; then
            echo "正在从网络获取$containerd_io"
            curl -L -O $URL/$containerd_io
        else
            echo "已经获取本地$containerd_io"
        fi
        sudo dpkg -i $containerd_io
        if [ ! -f "./$docker_ce_cli" ]; then
            echo "正在从网络获取$docker_ce_cli"
            curl -L -O $URL/$docker_ce_cli
        else
            echo "已经获取本地$docker_ce_cli"
        fi
        sudo dpkg -i $docker_ce_cli
        if [ ! -f "./$docker_compose_plugin" ]; then
            echo "正在从网络获取$docker_compose_plugin"
            curl -L -O $URL/$docker_compose_plugin
        else
            echo "已经获取本地$docker_compose_plugin"
        fi
        sudo dpkg -i $docker_compose_plugin
        if [ ! -f "./$docker_ce" ]; then
            echo "正在从网络获取$docker_ce"
            curl -L -O $URL/$docker_ce
        else
            echo "已经获取本地$docker_ce"
        fi
        sudo dpkg -i $docker_ce
        sudo dpkg -i $docker_ce

        shell=$(env | grep SHELL=)
        echo $shell
        if [ ! -d "/etc/docker" ]; then
            sudo mkdir /etc/docker
        fi
        if [ ! -f "/etc/docker/daemon.json" ]; then
            sudo touch /etc/docker/daemon.json
        fi
        # sudo gedit /etc/docker/daemon.json
        # 南京大学：https://docker.nju.edu.cn
        # 中国科技大学：https://docker.mirrors.ustc.edu.cn
        sudo sh -c 'echo "{\"registry-mirrors\": [\"https://docker.nju.edu.cn\"]}"> /etc/docker/daemon.json'
        sudo service docker restart
        docker -v
        sudo docker run hello-world
        echo
        echo -e "\e[32m如果安装过程出现错误请再次运行./docker.sh 1\e[0m"
    elif [ $1 = "0" ]; then
        error=0
        sudo service docker stop
        sudo dpkg --purge docker-ce docker-ce-cli docker-compose-plugin containerd.io
        sudo apt-get remove docker docker-engine docker.io containerd runc
        sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
        sudo rm -rf /var/lib/docker /var/lib/containerd
        sudo rm -rf /etc/docker /var/run/docker /var/run/docker.sock
        sudo groupdel docker
    elif [ $1 = "h" ]; then
        error=0
        echo "https://docs.docker.com/get-started/"
        echo "https://docs.docker.com/samples/"
        echo "git clone https://github.com/docker/labs.git"
        echo
        echo "docker --help"
        echo
        echo "查看docker详细信息"
        echo "docker info"
        echo
        echo "---------------------------------------------镜像命令---------------------------------------------------------"
        echo "查看本地镜像"
        echo "sudo docker images [options]"
        echo "options: -a [列出所有镜像（含中间映像层），没有此参数的docker images 仅仅展现的是镜像的最外层镜像信息--->镜像是分层的]"
        echo "         -q [列出镜像的{IMAGE ID}]"
        echo "         -qa [列出所有镜像的{IMAGE ID}]"
        echo "         --digests [显示镜像的摘要信息]"
        echo "         --no-trunc [显示完整的镜像信息]"
        echo
        echo "查找镜像"
        echo "docker search [options] {Image Name}"
        echo "options: --no-trunc [显示完整的镜像描述]"
        echo "         -s [列出收藏数不小于指定值的镜像 “docker search -s 30 tomcat”]"
        echo "         --automated [只列出automated build类型的镜像]"
        echo
        echo "拉取镜像hello-world到本地"
        echo "sudo docker pull hello-world"
        echo
        echo "删除镜像hello-world"
        echo "sudo docker rmi hello-world"
        echo
        echo "删除所有镜像"
        echo "sudo docker rmi \$(sudo docker images -qa)"
        echo
        echo "-------------------------------------------容器命令-------------------------------------------------------------"
        echo "新建并启动容器"
        echo "docker run [options] {IMAGES} [COMMAND] [ARG...]"
        echo "options:   --name=\"容器新名字\":为容器指定一个名称"
        echo "           -d:后台运行容器，并返回容器ID，即启动守护进程"
        echo "           -i:以交互模式运行容器，通常与-t同时使用"
        echo "           -t:为容器重新分配一个伪输入终端，通常与-i同时使用"
        echo "           -P:随机端口映射"
        echo "           -p:指定端口映射 [主机端口:docker容器端口]，有以下四种格式:"
        echo "                          ip:hostPort:containerPort"
        echo "                          ip::containerPort"
        echo "                          hostPort:containerPort"
        echo "                          containerPort"
        echo "[example] docker run -it --name myproject centos [运行并进入容器，即进入交互式容器]"
        echo "[example] docker run -d centos [后台运行容器，并返回容器ID，即启动守护式容器]"
        echo
        echo "列出当前所有正在运行的容器"
        echo "docker ps [options]"
        echo "options:  -a:列出当前所有正在运行的容器+历史上运行过的"
        echo "          -l:显示最近创建的容器"
        echo "          -n:显示最近n个创建的容器 [docker ps -n 2 :过去启动的两个容器]"
        echo "          -q:静默模式，只显示容器编号 [正在运行的容器]"
        echo "          --no-trunc:不截断输出"
        echo
        echo "退出容器"
        echo "1/ exit[容器停止退出]        2/ ctrl+P+Q[容器不停止退出]"
        echo
        echo "重新启动已经退出的容器"
        echo "docker start {Container ID}"
        echo
        echo "重启正在运行的容器"
        echo "docker restart {Container ID}"
        echo
        echo "停止正在运行的容器"
        echo "docker stop {Container ID}"
        echo "停止所有容器"
        echo "docker stop \$(docker ps -a -q)"
        echo
        echo "强制停止正在运行的容器"
        echo "docker kill {Container ID} [相比于stop更快，相当于直接拔电源]"
        echo "杀死所有正在运行的容器"
        echo "docker kill \$(docker ps -a -qa)"
        echo
        echo "删除已经停止的容器"
        echo "docker ps -l && docker ps -n 2"
        echo "docker rm {Container ID}"
        echo
        echo "一次性删除多个容器"
        echo "docker rm -f \$(docker ps -a -q)"
        echo "docker ps -a -q | xargs docker rm "
        echo
        echo "重命名容器"
        echo "sudo docker rename [OLD NAMES] [NEW NAMES]"
        echo
        echo "查看容器日志"
        echo "docker logs -f -t --tail {Container ID}"
        echo "options: -t [加入的时间戳]"
        echo "         -f [跟新最新的日志打印]"
        echo "         --tail [数字 显示最后几条]"
        echo
        echo "使得守护式容器不退出"
        echo "docker run -d centos /bin/sh -c 'while true; do echo hello hsq; sleep 2; done'"
        echo "docker logs -f -t --tail 3 {Container ID}"
        echo
        echo "查看容器内部运行的进程"
        echo "docker top {Container ID}"
        echo
        echo "查看容器内部的细节"
        echo "docker inspect {Container ID}"
        echo
        echo "进入正在运行的容器并以命令行交互"
        echo "docker exec -it {Container ID} /bin/bash"
        echo "          ----在容器中打开新的终端，并且可以启动新的进程"
        echo "docker attach {Container ID}"
        echo "          ----直接进入容器启动命令的终端，不会启动新的进程"
        echo
        echo "从容器内拷贝文件到主机上"
        echo "docker cp {Container ID}:容器内路径 目的主机命令"
        echo
        echo "提交容器副本使之成为一个新的镜像"
        echo "docker commit -m='提交的描述信息' -a='作者' {Container ID} 要创建的目标镜像名称:[标签名]"
        echo
        echo "-----------------------------------------其他命令---------------------------------------------------"
        echo "启动docker服务"
        echo "sudo service docker start"
        echo
        echo "关闭docker服务"
        echo "sudo service docker stop"
        echo
        echo "重启docker服务"
        echo "sudo service docker restart"
        echo
        echo "自动清理"
        echo "sudo docker system prune"
        echo
        echo "使用Dockerfile文件创建新镜像"
        echo "拉取base镜像"
        echo "sudo docker pull alpine:3.5"
        echo "cd \${HOME}"
        echo "git clone https://github.com/docker/labs.git"
        echo "cd labs/beginner/flask-app"
        echo
        echo "gedit Dockerfile"
        echo "在# Install python and pip前添加如下内容"
        echo "RUN sed -i \"s/dl-cdn.alpinelinux.org/mirrors.agedit Dockerfileiyun.com/g\" /etc/apk/repositories"
        echo "RUN mkdir ~/.pip"
        echo "RUN echo \"[global]\">> ~/.pip/pip.conf"
        echo "RUN echo \"index-url = http://mirrors.aliyun.com/pypi/simple/\">> ~/.pip/pip.conf"
        echo "RUN echo \"[install]\">> ~/.pip/pip.conf"
        echo "RUN echo \"trusted-host = mirrors.aliyun.com\">> ~/.pip/pip.conf"
        echo
        echo "docker build --help"
        echo "sudo docker build -t qqzad/myapp ."
        echo "sudo docker run -p 8888:5000 --name myapp qqzad/myapp"
        echo "访问http://localhost:8888 // curl localhost:8888"
        echo
        echo "使用容器创建新镜像"
        echo "sudo docker commit [CONTAINER ID]/[NAMES] qqzad/newapp"
        echo
        echo "检查docker用户组是否存在"
        echo "grep docker /etc/group"
        echo
        echo "在系统中添加docker用户组"
        echo "sudo groupadd docker"
        echo
        echo "将用户adzhu添加到docker用户组"
        echo "sudo usermod -aG docker adzhu"
        echo
        echo "重启docker服务"
        echo "sudo systemctl restart docker"
        echo
        echo "用户adzhu重新登录后运行docker pull hello-world"
    fi
fi
if [ $error = "1" ]; then
    echo "./docker.sh 1     安装docker"
    echo "./docker.sh 0     卸载docker"
    echo "./docker.sh h     关于docker"
fi
