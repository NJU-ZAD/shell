#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo -e "\e[32m[系统命令]\e[0m"
echo
echo "严禁卸载Ubuntu自带的Python或Python3"
echo
echo "重启"
echo "reboot"
echo
echo "关机"
echo "shutdown"
echo
echo "查看所有用户信息"
echo "grep bash /etc/passwd"
echo
echo "创建用户user_name"
echo "（1）默认无用户密码，无主目录，无法登录图形界面"
echo "sudo useradd user_name"
echo "（2）需指定用户信息，创建主目录，可以登录图形界面"
echo "sudo adduser user_name"
echo
echo "设置用户user_name的密码"
echo "sudo passwd user_name"
echo
echo "修改用户user_name的名称为new_user_name"
echo "sudo usermod -l new_user_name user_name"
echo
echo "删除用户user_name"
echo "sudo userdel user_name"
echo
echo "查看所有用户组信息"
echo "getent group"
echo "用户组的名称:组密码:组ID:用户列表"
echo
echo "查看包含当前用户的全部用户组"
echo "groups"
echo
echo "查看包含用户\${USER}的全部用户组"
echo "groups \${USER}"
echo
echo "创建用户组group_name"
echo "sudo groupadd group_name"
echo
echo "修改用户组group_name的名称为new_group_name"
echo "sudo groupmod -n new_group_name group_name"
echo
echo "将用户\${USER}添加到用户组group_name中"
echo "sudo usermod -aG group_name \${USER}"
echo
echo "将用户\${USER}从用户组group_name中去除"
echo "sudo gpasswd -d \${USER} group_name"
echo
echo "删除用户组group_name"
echo "sudo groupdel group_name"
echo
echo "改变文件/文件夹的主人"
echo "sudo chown \${USER}: -R name"
echo
echo "使所有用户对文件夹test及其子项拥有最高权限"
echo "sudo chmod -R 777 test"
echo "chmod后面的参数分别是所有者权限、组权限、其他权限"
echo "111表示可读可写可执行，十进制为7"
echo "110表示可读可写不可执行，十进制为6"
echo "101表示可读不可写可执行，十进制为5"
echo "100表示可读不可写不可执行，十进制为4"
echo
echo "所有者：文件的创建者"
echo "组：所有者所在的组"
echo "其他：除了所有者和组中用户的其他系统用户"
echo
echo "ls的用法ls --help"
echo "-l使用较长格式列出信息，包括权限和所有者信息"
echo "-a不隐藏任何以. 开始的项目"
echo "-d仅现实目录本身"
echo
echo "杀死图形进程"
echo "xkill"
echo
echo "查看进程资源占用情况（q退出，空格刷新）"
echo "top"
echo
echo "杀死chrome的所有进程"
echo "killall chrome"
echo
echo "杀死进程"
echo "sudo kill -9 PID"
echo
echo "为文件添加/取消可执行权限"
echo "chmod +/-x 'file name'"
echo
echo "为当前目录下所有文件添加/取消可执行权限"
echo "chmod +/-x *"
echo
echo "为当前目录下所有txt文件添加/取消可执行权限"
echo "chmod +/-x *.txt"
echo
echo "查看所有文件"
echo "ls -a"
echo
echo "查看所有文件的详细信息"
echo "ls -la"
echo
echo "新建文件"
echo "touch ~/'file name.txt'"
echo
echo "新建文件夹"
echo "mkdir ~/'floder name'"
echo
echo "重命名文件(注意：通过ls获取文件的正确名称)"
echo "sudo mv ~/'file name.txt' ~/'new file name.txt'"
echo
echo "重命名文件夹(注意：通过ls获取文件夹的正确名称)"
echo "sudo mv ~/'floder name' ~/'new floder name'"
echo
echo "复制文件(注意：通过ls获取文件的正确名称)"
echo "sudo cp ~/'file name.txt' /'file name.txt'"
echo
echo "复制文件夹中所有文件至另一个文件夹(直接替换同名文件)"
echo "\cp -r ~/'floder name'/* ~/'other floder name'/"
echo
echo "复制文件夹(注意：通过ls获取文件夹的正确名称)"
echo "sudo cp -r ~/'floder name' /"
echo
echo "移动文件(注意：通过ls获取文件的正确名称)"
echo "sudo mv ~/'file name.txt' /'file name.txt'"
echo
echo "移动文件夹(注意：通过ls获取文件夹的正确名称)"
echo "sudo mv ~/'floder name' /"
echo
echo "删除文件(注意：通过ls获取文件的正确名称)"
echo "sudo rm -rf ~/'file name.txt'"
echo
echo "删除文件夹(注意：通过ls获取文件夹的正确名称)"
echo "sudo rm -rf ~/'floder name'"
echo
echo "压缩与解压缩(注意：通过ls获取文件(文件夹)的正确名称)"
echo "zip --help"
echo "unzip --help"
echo
echo "*.zip"
echo "zip -q -r 'floder name.zip' 'floder name'"
echo "unzip -q 'floder name.zip'"
echo
echo "sudo apt-get install p7zip-full -y"
echo "7z --help"
echo
echo "*.7z"
echo "7z a 'floder name.7z' 'floder name'"
echo "7z x 'floder name.7z'"
echo
echo "*.7z分卷"
echo "7z a 'floder name.7z' 'floder name' -v512m"
echo "7z x 'floder name.7z.001'"
echo
echo "sudo apt-get install rar unrar -y"
echo "rar"
echo "unrar"
echo
echo "*.rar"
echo "rar a 'floder name.rar' 'floder name'"
echo "unrar x 'floder name.rar'"
echo
echo "tar --usage"
echo "tar --help"
echo
echo "*.tar"
echo "tar -zcf 'floder name.tar' 'floder name'"
echo "tar -xf 'floder name.tar'"
echo
echo "*.tar分卷"
echo "tar -zcf - 'floder name' | split -b 64M - 'floder name.tar'"
echo "cat 'floder name'* | tar -xz"
echo
echo "*.tar.gz"
echo "tar -zcf 'floder name.tar.gz' 'floder name'"
echo "tar -xf 'floder name.tar.gz'"
echo
echo "*.tar.tgz"
echo "tar -zcf 'floder name.tar.tgz' 'floder name'"
echo "tar -xf 'floder name.tar.tgz'"
echo
echo "*.tgz"
echo "tar -zcf 'floder name.tgz' 'floder name'"
echo "tar -xf 'floder name.tgz'"
echo
echo "xz --help"
echo
echo "*.tar.xz"
echo "tar -zcf 'floder name.tar' 'floder name'"
echo "xz -z 'floder name.tar'"
echo "xz -d 'floder name.tar.xz'"
echo "tar -xf 'floder name.tar'"
echo
echo "安装新的软件包"
echo "sudo apt-get install"
echo
echo "查看所有已安装的软件包"
echo "dpkg -l"
echo
echo "卸载软件包以及配置文件"
echo "sudo apt-get --purge remove"
echo
echo "返回父目录"
echo "cd .."
echo
echo "Gedit查找和替换"
echo "Ctrl+H"
echo
echo "显示Nautilus地址栏"
echo "Ctrl+L"
echo
echo "显示Nautilus隐藏文件"
echo "Ctrl+H"
echo
echo "收藏Nautilus文件夹"
echo "Ctrl+D"
echo
echo "创建软链接（原文件为~/file.txt）"
echo "ln -s ~/file.txt ~/floder/file.txt"
echo
echo "查看内核信息"
echo "uname -a"
echo
echo "查看Ubuntu版本"
echo "cat /etc/issue"
echo
echo "查看CPU信息"
echo "cat /proc/cpuinfo"
echo
echo "查看内存信息"
echo "sudo dmidecode --type memory"
echo
echo "查看GPU信息"
echo "echo \$(lspci|grep -i vga)"
echo
echo "查看网卡型号"
echo "lspci|grep -E \"Ethernet controller|Network controller\""
echo
echo "查看USB设备"
echo "lsusb"
echo
echo "查看PCI设备"
echo "lspci"
echo
echo "查看当前硬件信息"
echo "sudo lshw"
echo
echo "查看磁盘信息"
echo "sudo fdisk -l"
echo
echo "查看文件系统使用情况"
echo "df -h"
echo
echo "查看文件系统格式"
echo "df -T"
echo
echo "查看当前的内存使用情况"
echo "free -m"
echo
echo "查看软件vim安装位置"
echo "dpkg -L vim"
echo "whereis vim"
echo "which vim"
echo "type vim"
echo
echo "在特定目录下快速查找文件或目录"
echo "sudo find 特定目录 -name 文件或目录"
echo
echo "立刻关闭计算机"
echo "sudo shutdown -r now"
echo
echo "定时关闭计算机（24小时制）"
echo "sudo shutdown -h 22:00"
echo
echo "安装MS字体"
echo "sudo apt-get install ttf-mscorefonts-installer"
echo
echo "列出会话窗口"
echo "screen -ls"
echo
echo "新建会话窗口"
echo "screen -S name"
echo
echo "分离会话窗口"
echo "Ctrl+A+D"
echo
echo "恢复会话窗口"
echo "(Attached)"
echo "screen -d id/name"
echo "(Detached)"
echo "screen -r id/name"
echo
echo "杀死会话窗口"
echo "kill -9 id"
echo
echo "清除死去窗口"
echo "screen -wipe"
echo
echo "切换输入法"
echo "Win+Space"
echo
echo "安装pip"
echo "sudo apt-get install python-pip"
echo
echo "更新pip"
echo "pip install --upgrade pip"
echo
echo "卸载pip"
echo "sudo apt-get remove python-pip"
echo
echo "用pip查看特定包"
echo "pip show"
echo
echo "用pip安装特定包"
echo "pip install numpy -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com"
echo
echo "用pip卸载特定包"
echo "pip uninstall"
echo
echo "安装pip3"
echo "sudo apt-get install python3-pip"
echo
echo "更新pip3"
echo "pip3 install --upgrade pip"
echo
echo "卸载pip3"
echo "sudo apt-get remove python3-pip"
echo
echo "用pip3查看特定包"
echo "pip3 show"
echo
echo "用pip3安装特定包"
echo "pip3 install numpy -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com"
echo
echo "用pip3卸载特定包"
echo "pip3 uninstall"
echo
echo "清除无用的软件包"
echo "sudo apt-get autoremove"
echo
echo "更新Linux系统内核"
echo "sudo apt-get install linux-headers-\$(uname -r)"
echo
echo "开启防火墙"
echo "sudo ufw enable"
echo
echo "关闭防火墙"
echo "sudo ufw disable"
echo
echo "查看防火墙状态"
echo "sudo ufw status"
echo
echo "查看ssh服务状态"
echo "service ssh status"
echo
echo "启动ssh服务"
echo "service ssh start"
echo
echo "停止ssh服务"
echo "service ssh stop"
echo
echo "重启ssh服务"
echo "service ssh restart"
echo
echo "开放防火墙ssh服务端口"
echo "sudo ufw allow ssh"
echo
echo "删除防火墙ssh服务端口"
echo "sudo ufw delete allow ssh"
echo
echo "U盘目录"
echo "cd /media/\${USER}"
echo "ls"
echo
echo "查看CPU线程数量"
echo "echo \`nproc\`"
echo
echo "设置root用户的密码"
echo "sudo passwd root"
echo
echo "查看已经登入的用户"
echo "who"
echo
echo "查看后台正在运行的程序"
echo "ps -aux"
echo
echo "安装新的动态链接库后"
echo "sudo ldconfig"
echo
echo "查看内核模块"
echo "lsmod"
echo
echo "查看所有网络设备"
echo "ifconfig -a"
echo
echo "关闭网卡"
echo "sudo ifconfig wlp2s0 down"
echo "sudo dhclient -r wlp2s0"
echo
echo "打开网卡"
echo "sudo ifconfig wlp2s0 up"
echo "sudo dhclient wlp2s0"
echo
echo "更新字体缓存"
echo "sudo fc-cache -fv"
echo
echo "为终端设置临时代理"
echo "sudo apt-get install curl -y"
echo "address=\"localhost:7890\""
echo "export http_proxy=socks5h://\$address"
echo "export https_proxy=socks5h://\$address"
echo "curl www.google.com"
echo
echo "使用代理的git"
echo "git clone https://github.com/qemu/meson.git"
echo "address=\"localhost:7890\""
echo "git -c http.proxy=socks5://\$address -c https.proxy=socks5://\$address -c socks.proxy=socks5://\$address clone https://github.com/qemu/meson.git"
echo
echo "使用代理的apt-get"
echo "address=\"localhost:7890\""
echo "sudo apt-get -o Acquire::http::proxy=socks5h://\$address -o Acquire::https::proxy=socks5h://\$address -o Acquire::socks::proxy=socks5h://\$address update"
echo
echo "通过tsocks强制代理wget"
echo "sudo apt-get install tsocks -y"
echo "address=\"localhost:7890\""
echo "set_port=\$(echo \"\${address#*:}\")"
echo "port=\$(grep -n \"server_port\" /etc/tsocks.conf)"
echo "port=\$(echo \"\${port#*:}\")"
# echo "echo \$port"
echo "sudo sed -i \"s/\$port/server_port = \$set_port/g\" /etc/tsocks.conf"
echo "set_server=\$(echo \"\${address%:*}\")"
echo "server=\$(grep -n \"server =\" /etc/tsocks.conf)"
echo "server=\$(echo \"\${server#*:}\")"
# echo "echo \$server"
echo "sudo sed -i \"s/\$server/server = \$set_server/g\" /etc/tsocks.conf"
echo "vim /etc/tsocks.conf"
echo "tsocks wget www.google.com"
echo
echo "格式化U盘为NTFS"
echo "df -h"
echo "sudo umount /dev/sdb1"
echo "sudo mkfs.ntfs /dev/sdb1"
echo
echo "将文档filename中的行按字典序排列（删除重复）"
echo "sort -u filename -o filename"
echo
echo "窗口向右/左停靠"
echo "Win+->/<-"
echo
echo "右键-显示菜单栏(M)-搜索(S)-查找(F)..."
echo
echo "Ubuntu系统中移动硬盘出现文档被锁定的问题，解决方案：Ctrl+H 删除该目录下对应的隐藏文件"
