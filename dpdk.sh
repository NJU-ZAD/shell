#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
MIRRORS="http://mirrors.aliyun.com/pypi/simple/"
HOST="mirrors.aliyun.com"
V=21.11
VER=$V.1
if [ -n "$1" ]; then
	if [ "$1" = "1" ]; then
		error=0
		echo "安装DPDK..."
		sudo apt-get install linux-headers-$(uname -r)
		sudo apt-get install make gcc build-essential pkg-config net-tools libnuma-dev python3-pyelftools -y
		pip3 install --upgrade pip -i $MIRRORS --trusted-host $HOST
		sudo pip3 install meson ninja -i $MIRRORS --trusted-host $HOST
		if [ ! -d "/mnt/huge" ]; then
			sudo mkdir /mnt/huge
		fi
		sudo mount -t hugetlbfs nodev /mnt/huge
		if [ $(grep -c "nodev /mnt/huge hugetlbfs defaults 0 0" /etc/fstab) -eq 0 ]; then
			sudo sh -c "echo nodev /mnt/huge hugetlbfs defaults 0 0 >> /etc/fstab"
		fi
		# sudo gedit /etc/fstab
		dpdk_tarxz=dpdk-$VER.tar.xz
		if [ ! -f "./$dpdk_tarxz" ]; then
			echo "正在从网络获取$dpdk_tarxz"
			curl -L -O https://fast.dpdk.org/rel/$dpdk_tarxz
		else
			echo "已经获取本地$dpdk_tarxz"
		fi
		if [ ! -d "${HOME}/dpdk-stable-$VER" ]; then
			tar xJf $dpdk_tarxz
			mv dpdk-stable-$VER ${HOME}/
		fi
		cd ${HOME}/dpdk-stable-$VER
		sudo meson build
		cd build
		sudo ninja
		sudo ninja install
		sudo ldconfig
		sudo chown ${USER}: -R ${HOME}/dpdk-stable-$VER
		echo "分配1024个hugepages-2048kB"
		sudo sh -c "echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
		echo "手动执行sudo reboot"
	elif [ "$1" = "0" ]; then
		error=0
		echo "卸载DPDK..."
		read -p "确保所有DPDK程序已停止且DPDK内核驱动被卸载"
		sudo apt-get remove --purge libnuma-dev python3-pyelftools -y
		sudo umount /mnt/huge
		sudo rm -rf /mnt/huge
		sudo sed -i "/hugetlbfs defaults 0 0/d" /etc/fstab
		if [ -d "${HOME}/dpdk-stable-$VER/build" ]; then
			cd ${HOME}/dpdk-stable-$VER/build
			sudo ninja uninstall
		fi
		sudo pip3 uninstall meson ninja -y
		sudo sh -c "echo 0 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
		sudo sh -c "echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages"
		rm -rf ${HOME}/dpdk-stable-$VER
	elif [ "$1" = "+" ]; then
		error=0
		echo "启动DPDK..."
		hugepages_small=$(head -n 1 "/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages")
		hugepages_big=$(head -n 1 "/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages")
		echo hugepages-2048kB"的数量为"$hugepages_small
		echo hugepages-1048576kB"的数量为"$hugepages_big
		if [ $hugepages_small -eq 0 ] && [ $hugepages_big -eq 0 ]; then
			echo "启动DPDK前必须分配一定数量的hugepages！"
			echo "sudo gedit /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
			echo "sudo gedit /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages"
			exit
		fi
		echo "通过lsmod查看所有内核模块"
		echo "加载内核模块uio_pci_generic..."
		sudo modprobe uio_pci_generic
		echo "加载内核模块uio..."
		sudo modprobe uio
		echo "加载内核模块igb_uio..."
		sudo insmod ${HOME}/dpdk-stable-$VER/build/kernel/linux/igb_uio/igb_uio.ko
		python3 ${HOME}/dpdk-stable-$VER/usertools/dpdk-devbind.py --status
		read -p "输入网络设备的名称" nic_name
		read -p "输入网络设备的ID（类似02:01.0）" nic_id
		sudo ifconfig $nic_name down
		echo "将设备$nic_id绑定至内核模块igb_uio..."
		sudo python3 ${HOME}/dpdk-stable-$VER/usertools/dpdk-devbind.py --bind=igb_uio $nic_id
		python3 ${HOME}/dpdk-stable-$VER/usertools/dpdk-devbind.py --status
	elif [ "$1" = "-" ]; then
		error=0
		echo "停止DPDK..."
		python3 ${HOME}/dpdk-stable-$VER/usertools/dpdk-devbind.py --status
		read -p "输入网络设备的ID（类似02:01.0）" nic_id
		echo "将网络设备$nic_id绑定至原始内核模块igb..."
		sudo python3 ${HOME}/dpdk-stable-$VER/usertools/dpdk-devbind.py --bind=e1000 $nic_id
		python3 ${HOME}/dpdk-stable-$VER/usertools/dpdk-devbind.py --status
		read -p "输入网络设备的名称" nic_name
		sudo ifconfig $nic_name up
		echo "卸载内核模块igb_uio模块..."
		sudo rmmod ${HOME}/dpdk-stable-$VER/build/kernel/linux/igb_uio/igb_uio.ko
		echo "卸载内核模块uio_pci_generic..."
		sudo modprobe -r uio_pci_generic
		echo "卸载内核模块uio模块..."
		sudo modprobe -r uio
		sudo sh -c "echo 0 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
		sudo sh -c "echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages"
	elif [ "$1" = "*" ]; then
		error=0
		echo "简单例子..."
		sudo sh -c "echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
		./dpdk.sh +
		cd ${HOME}/dpdk-stable-$VER/examples/helloworld/
		export RTE_SDK=${HOME}/dpdk-stable-$VER
		export RTE_TARGET=x86_64-native-linux-gcc
		sudo make
		cd build
		sudo ./helloworld -l 0-3
		echo "cd ${HOME}/dpdk-stable-$VER/examples/helloworld;sudo make clean"
	fi
elif [ ! -n "$1" ]; then
	error=0
	echo "下载DPDK"
	echo "https://core.dpdk.org/download/"
	echo
	echo "DPDK支持的Intel网卡"
	echo "https://core.dpdk.org/supported/nics/intel/"
	echo
	echo "DPDK支持的使用e1000内核驱动的VM网卡"
	echo "82540, 82545, 82546"
	echo
	echo "获取本机网卡型号"
	echo "lspci | grep -E \"Ethernet controller|Network controller\""
	lspci | grep -E "Ethernet controller|Network controller"
	echo
	echo "DPDK $V编程API"
	echo "https://doc.dpdk.org/api-$V/index.html"
	echo
	echo "查看系统所支持的hugepages的大小"
	echo "ls /sys/kernel/mm/hugepages"
	ls /sys/kernel/mm/hugepages
	echo
	echo "查看已经分配的hugepages的数量"
	echo "cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
	cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
	echo "cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages"
	cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
	echo
	echo "查看是否支持NUMA"
	echo "ls /sys/devices/system/node"
	ls /sys/devices/system/node
	echo
	echo "lib	库文件"
	echo "rte	Runtime environment"
	echo
	echo "获取DPDK的官方pdf文档"
	echo "https://fast.dpdk.org/doc/pdf-guides"
	echo "curl -L -O http://static.dpdk.org/doc/pdf-guides/linux_gsg-20.08.pdf -O \"Getting Started Guide for Linux.pdf\""
	echo "curl -L -O http://static.dpdk.org/doc/pdf-guides/nics-20.08.pdf -O \"Network Interface Controller Drivers.pdf\""
	echo "curl -L -O http://static.dpdk.org/doc/pdf-guides/prog_guide-20.08.pdf -O \"Programmer’s Guide.pdf\""
	echo
	echo "DPDK调bug技巧"
	echo "DPDK程序运行遇到问题运行grep -r -E \"报错信息中的关键部分\" ~/dpdk-stable-$VER"
	echo "在DPDK的源码中定位到相关行，根据对应的if条件修改自己的代码"
fi

if [ $error -eq 1 ]; then
	echo "./dpdk.sh 寻求帮助"
	echo "./dpdk.sh 1 安装DPDK"
	echo "./dpdk.sh 0 卸载DPDK"
	echo "./dpdk.sh + 启动DPDK"
	echo "./dpdk.sh - 停止DPDK"
	echo "./dpdk.sh * 简单例子"
fi
