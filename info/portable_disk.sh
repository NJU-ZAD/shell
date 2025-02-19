#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo "在移动硬盘上安装Ubuntu系统"
echo "【1】确保BIOS支持从移动硬盘启动：联想主板->F2->BIOS->Boot->USB Boot->Enabled"
echo "【2】在移动硬盘上压缩出空闲空间：Windows磁盘管理->移动硬盘->压缩卷->102400MB"
echo "【3】在移动硬盘上创建Ubuntu分区和引导分区：Ubuntu启动盘->Try Ubuntu->运行GParted->在空闲空间上创建Ubuntu分区和引导分区（100MB）->将Ubuntu分区格式化为ext4->将引导分区格式化为fat32"
echo "【4】在移动硬盘上安装Ubuntu系统：安装类型->其它类型->选择Ubuntu分区->更改->用于Ext4日志文件系统->格式化此分区->挂载到/->选择引导分区->更改->用于EFI系统分区->安装启动引导器的设备->引导分区"
echo "【5】从移动硬盘上启动Ubuntu系统：联想主板->F2->BIOS->Boot->移动硬盘上的Ubuntu分区"
echo -e "\e[31m若发现Ubuntu引导仍然安装在本地磁盘\e[0m"
echo "【6】在Windows上使用EasyUEFI将本地磁盘引导分区移动/复制到移动硬盘引导分区"
echo "【7】在Windows上使用DiskGenius删除本地磁盘引导中BOOT和ubuntu文件夹以及移动硬盘引导中Microsoft文件夹"
echo "【8】在Ubuntu上运行~/shell/update_system_time.sh更新Windows系统的时间"
echo -e "\e[31m若在BIOS中没有发现Ubuntu引导，应该手动关机重新插拔移动硬盘后再开机\e[0m"
