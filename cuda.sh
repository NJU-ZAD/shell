#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1

check_system() {
    release_num=$(lsb_release -r --short)
    case "$release_num" in
    "22.04")
        echo -e "\e[32m获取当前Ubuntu版本$release_num\e[0m"
        ubuntu=ubuntu2204
        ;;
    "20.04")
        echo -e "\e[32m获取当前Ubuntu版本$release_num\e[0m"
        ubuntu=ubuntu2004
        ;;
    "18.04")
        echo -e "\e[32m获取当前Ubuntu版本$release_num\e[0m"
        ubuntu=ubuntu1804
        ;;
    *)
        echo -e "\e[32m当前Ubuntu版本$release_num不支持CUDA Toolkit $cuda_ver\e[0m"
        exit
        ;;
    esac
}

#* https://developer.nvidia.com/tools-overview/nsight-compute/get-started#latest-version
nsight_compute_ver=2024.2
nsight_compute=nsight-compute-linux-${nsight_compute_ver}.0.16-34181891.run

if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        #* CUDA版本由PyTorch版本决定
        #* https://pytorch.org/get-started/locally/
        #* https://developer.nvidia.com/cuda-toolkit-archive
        # cuda_ver=12.4.1
        read -p "请指定CUDA Toolkit的版本号" cuda_ver
        if ! [[ $cuda_ver =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "输入错误，结束安装"
            exit
        fi
        cver=$(echo $cuda_ver | sed 's/\./-/g')
        check_system
        cver_main="${cver%-*}"
        first="${cver_main%-*}"
        second="${cver_main#*-}"
        if [ "$first" = "11" ] && [ "$second" -ge 3 ]; then
            cuda_install_url="https://developer.nvidia.com/cuda-$cver-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=$release_num&target_type=deb_local"
        else
            cuda_install_url="https://developer.nvidia.com/cuda-$cver-download-archive?target_os=Linux&Distribution=Ubuntu&target_arch=x86_64&target_distro=Ubuntu&target_version=$release_num&target_type=deblocal"
        fi
        echo "$cuda_install_url"
        repo="cuda-repo-$ubuntu-${cver_main}-local_${cuda_ver}-"
        PATTERN="${repo}[^_]*_amd64.deb"
        deb=$(curl -Lks $cuda_install_url | grep -oP "$PATTERN" | head -n 1)
        # echo $deb
        if [ -z "$deb" ]; then
            echo "互联网连接存在问题或者指定的CUDA Toolkit版本号不存在！"
            exit
        fi
        driver_ver=$(echo $deb | sed -n "s/$repo\([^_]*\)_amd64.deb/\1/p")
        driver_ver="${driver_ver%%.*}"
        # echo $driver_ver
        repo_ver=cuda-repo-$ubuntu-${cver_main}-local
        pin_url=https://developer.download.nvidia.com/compute/cuda/repos/$ubuntu/x86_64/cuda-$ubuntu.pin
        deb_url=https://developer.download.nvidia.com/compute/cuda/$cuda_ver/local_installers/$deb

        sudo apt-get install gcc bumblebee curl -y
        echo "更新系统内核..."
        sudo apt-get install linux-headers-$(uname -r)
        gccv=$(gcc --version | awk 'NR==1{print $NF}')
        kgccv=$(cat /proc/version | grep -oP 'gcc.*\K\d+\.\d+\.\d+,' | sed 's/,$//')
        if [ "$gccv" = "$kgccv" ]; then
            echo "内核的gcc版本与apt的gcc版本相同（${gccv}）"
        else
            echo -e "\e[31m内核的gcc版本（${kgccv}）与apt的gcc版本（${gccv}）不同\e[0m"
            echo -e "\e[31m建议使用更稳定的Ubuntu 20.04以避免此类问题\e[0m"
        fi
        echo
        echo "获取GPU设备信息："
        echo $(lspci | grep -i vga)
        echo "在安装前请访问官网查询你的NVIDIA GPU是否支持cuda以及支持的cuda版本"
        echo "对于较新的GPU参见https://developer.nvidia.com/cuda-gpus"
        echo "对于较老的GPU参见https://developer.nvidia.com/cuda-legacy-gpus"
        echo "通过运行lspci|grep -i nvidia命令可以验证设备GPU是否支持cuda"
        echo
        read -p "确保设备有足够的磁盘空间，是否继续安装CUDA Toolkit $cuda_ver ？(Y-继续/n-结束)" conti
        if [ $conti = "y" ] || [ $conti = "Y" ]; then
            echo "安装cuda..."
        elif [ $conti = "n" ] || [ $conti = "N" ]; then
            echo "结束安装"
            exit
        else
            echo "输入错误，结束安装"
            exit
        fi
        if [ ! -f "cuda-$ubuntu.pin" ]; then
            echo -e "\e[32m正在从网络获取cuda-$ubuntu.pin...\e[0m"
            echo "$pin_url"
            curl -L -O "$pin_url"
        else
            echo -e "\e[32m已经获取本地cuda-$ubuntu.pin\e[0m"
        fi
        if [ ! -f "cuda-$ubuntu.pin" ]; then
            echo "cuda-$ubuntu.pin下载失败或本地没有cuda-$ubuntu.pin"
            echo "结束安装"
            exit
        else
            sudo cp cuda-$ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
        fi
        if [ ! -f "$deb" ]; then
            echo -e "\e[32m正在从网络获取$deb...\e[0m"
            echo "$deb_url"
            curl -L -O "$deb_url"
        else
            echo -e "\e[32m已经获取本地$deb\e[0m"
        fi
        if [ ! -f "$deb" ]; then
            echo "$deb下载失败或本地没有$deb"
            echo "结束安装"
            exit
        else
            echo "OK"
            sudo dpkg -i $deb
            # sudo apt-key add /var/$repo_ver/7fa2af80.pub
            sudo cp /var/$repo_ver/cuda-*-keyring.gpg /usr/share/keyrings/
            sudo apt-get update
            sudo ubuntu-drivers install nvidia:${driver_ver}
            if [ "$first" = "12" ] && [ "$second" -ge 3 ]; then
                cuda_apt=cuda-toolkit-${cver_main}
            else
                cuda_apt=cuda
            fi
            sudo apt-get -y install $cuda_apt
            echo
            echo "已成功安装CUDA Toolkit $cuda_ver"
            echo "通过reboot命令重启机器"
        fi
    elif [ $1 = "2" ]; then
        # 本地必须存在$nsight_compute
        error=0
        if [ ! -f "$nsight_compute" ]; then
            echo "没有找到$nsight_compute"
            echo "访问https://developer.nvidia.com/nsight-compute"
            echo "获取$nsight_compute并将其放在shell下"
            echo "结束安装"
            exit
        else
            echo -e "\e[32m已经获取本地$nsight_compute\e[0m"
        fi
        echo -e "\e[31m请复制路径/usr/local/NVIDIA-Nsight-Compute-$nsight_compute_ver\e[0m"
        read -p "按回车键继续..."
        sudo chmod +x $nsight_compute
        sudo ./$nsight_compute
    elif [ $1 = "3" ]; then
        error=0
        echo "正在设置环境变量..."
        shell=$(env | grep SHELL=)
        echo $shell
        if [ $shell = "SHELL=/bin/bash" ]; then
            rc=.bashrc
        else
            rc=.zshrc
        fi
        if [ $(grep -c "export PATH=/usr/local/cuda/bin:/usr/local/NVIDIA-Nsight-Compute-$nsight_compute_ver\${PATH:+:\${PATH}}" /etc/bash.bashrc) -eq 0 ]; then
            sudo sed -i "\$a export PATH=/usr/local/cuda/bin:/usr/local/NVIDIA-Nsight-Compute-$nsight_compute_ver\${PATH:+:\${PATH}}" /etc/bash.bashrc
        fi
        source /etc/bash.bashrc
        # sudo gedit /etc/bash.bashrc
        if [ $(grep -c "export PATH=/usr/local/cuda/bin:/usr/local/NVIDIA-Nsight-Compute-$nsight_compute_ver\${PATH:+:\${PATH}}" ${HOME}/$rc) -eq 0 ]; then
            sed -i "\$a export PATH=/usr/local/cuda/bin:/usr/local/NVIDIA-Nsight-Compute-$nsight_compute_ver\${PATH:+:\${PATH}}" ${HOME}/$rc
        fi
        if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_CONNECTION" ]; then
            echo "请手动运行source ${HOME}/$rc"
        else
            if [ $shell = "SHELL=/bin/bash" ]; then
                gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
            else
                gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
            fi
        fi
        # gedit ${HOME}/.bashrc
        # gedit ${HOME}/.zshrc
        sudo chown ${USER}: -R /usr/local/cuda*
        sudo chmod -R 755 /usr/local/cuda*
        echo "已成功配置CUDA Toolkit $cuda_ver"
        echo -e "\e[32m必须在新终端中使用nvcc -V\e[0m"
        # https://github.com/NVIDIA/cuda-samples.git
        if [ ! -d "/usr/local/cuda/cuda-samples" ]; then
            if [ ! -f "cuda-samples.zip" ]; then
                echo "在shell中没有找到cuda-samples.zip"
                echo "结束配置"
                exit
            else
                echo -e "\e[32m已经获取本地cuda-samples.zip\e[0m"
            fi
            if [ ! -d "cuda-samples/" ]; then
                unzip -q cuda-samples.zip
            fi
            sudo mv cuda-samples /usr/local/cuda/
        fi
        cd /usr/local/cuda/cuda-samples
        git pull
        cd Samples/1_Utilities/deviceQueryDrv
        sudo make
        sudo ./deviceQueryDrv
        sudo make clean
        nvidia-smi
        echo -e "\e[32m通过nvidia-smi查询NVIDIA驱动\e[0m"
        echo
        echo -e "\e[32m通过sudo kill -9 [PID]可以强制结束GPU进程\e[0m"
    elif [ $1 = "0" ]; then
        error=0
        read -p "是否继续卸载CUDA Toolkit？(Y-继续/n-结束)" conti
        if [ $conti = "y" ] || [ $conti = "Y" ]; then
            echo "卸载cuda..."
        elif [ $conti = "n" ] || [ $conti = "N" ]; then
            echo "取消卸载"
            exit
        else
            echo "输入错误，取消卸载"
            exit
        fi
        sudo rm -rf /usr/local/cuda/cuda-samples
        sudo apt-get --purge remove "*cuda*" "*cublas*" "*cufft*" "*cufile*" "*curand*" "*cusolver*" "*cusparse*" "*gds-tools*" "*npp*" "*nvjpeg*" "nsight*" "*nvvm*" -y
        sudo apt-get autoremove -y
        sudo rm -rf /usr/local/cuda* /usr/local/NVIDIA-Nsight-Compute* /var/crash/nvidia-dkms*
        shell=$(env | grep SHELL=)
        echo $shell
        if [ $shell = "SHELL=/bin/bash" ]; then
            rc=.bashrc
        else
            rc=.zshrc
        fi
        sed -i "/cuda/d" ${HOME}/$rc
        sudo sed -i "/cuda/d" /etc/bash.bashrc
        sudo rm -rf /etc/X11/xorg.conf
        echo
        echo "通过运行sudo apt-get --purge remove \"*nvidia*\" \"libxnvctrl*\" -y命令可以卸载NVIDIA驱动程序"
    elif [ $1 = "+" ]; then
        error=0
        echo -e "\e[32mIntel核显专门用于输出\e[0m"
        echo -e "\e[32mNVIDIA独显专门用于计算\e[0m"
        # sudo rm -rf /etc/X11/xorg.conf
        # sudo gedit /etc/X11/xorg.conf
        echo -e "\e[32mlspci | grep VGA | grep Intel\e[0m"
        # 从lspci获得的BusID是十六进制
        # xorg.conf中的BusID必须为十进制
        input=$(lspci | grep VGA | grep Intel)
        if [ -z "$input" ]; then
            echo -e "\e[31m没有找到Intel显卡\e[0m"
            echo -e "\e[32m建议进入BIOS并执行以下操作\e[0m"
            echo -e "\e[32m【1】Security->Secure Boot->Disabled\e[0m"
            echo -e "\e[32m【2】Configuration->Graphic Device->Switchable Graphics\e[0m"
            exit
        fi
        echo -e "\e[32m获取Intel显卡的BusID...\e[0m"
        input="${input%% *}"
        input1="${input%:*}"
        input2="${input#*:}"
        input2="${input2%.*}"
        input3="${input#*.}"
        input1=$((16#$input1))
        input2=$((16#$input2))
        input3=$((16#$input3))
        # echo $input1
        # echo $input2
        # echo $input3
        BusID="${input1}:${input2}:${input3}"
        echo -e "\e[32mBusID为$BusID\e[0m"
        if [ ! -f "/etc/X11/xorg.conf" ]; then
            touch xorg.conf
            case "$release_num" in
            "20.04" | "22.04")
                cat >xorg.conf <<END_TEXT
Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0"
EndSection

Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
EndSection

Section "Device"
    Identifier     "Device0"
    Driver         "modesetting"
    VendorName     "Intel Corporation"
    BusID          "PCI:$BusID
EndSection
END_TEXT
                ;;
            "18.04")
                sudo cat >xorg.conf <<END_TEXT
Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0"
EndSection

Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
EndSection

Section "Device"
    Identifier     "Device0"
    Driver         "intel"
    VendorName     "Intel Corporation"
    BusID          "PCI:$BusID
EndSection
END_TEXT
                ;;
            *)
                exit
                ;;
            esac
            sudo mv xorg.conf /etc/X11/xorg.conf
        fi
        echo -e "\e[32m重启后Processes栏应显示No running processes found\e[0m"
        nvidia-smi
    fi
fi
if [ $error = "1" ]; then
    echo "https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html"
    echo "./cuda.sh 1   安装NVIDIA Cuda"
    echo "./cuda.sh 2   安装Nsight Compute"
    echo "./cuda.sh 3   配置NVIDIA Cuda和Nsight Compute"
    echo "./cuda.sh 0   卸载NVIDIA Cuda和Nsight Compute"
    echo "./cuda.sh +   优化核显和独显的运行模式为远程控制作准备"
    echo "https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html"
fi
