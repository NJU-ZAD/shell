#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo "https://gitee.com/ainilili/ratel.git"
read -p "确保在正确安装java和maven后继续"
cd ${HOME}
if [ ! -d "ratel" ]; then
    git clone https://gitee.com/ainilili/ratel.git
    cd ratel
else
    cd ratel
    git pull
fi
mvn install package
shell=$(env | grep SHELL=)
echo $shell
if [ $shell = "SHELL=/bin/bash" ]; then
    gnome-terminal -- /bin/sh -c 'java -jar landlords-server/target/landlords-server* -p 1024;exec bash'
else
    gnome-terminal -- /bin/zsh -c 'java -jar landlords-server/target/landlords-server* -p 1024;exec zsh'
fi
sleep 3
java -jar landlords-client/target/landlords-client* -p 1024 -h 127.0.0.1
