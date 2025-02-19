#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo "1.开机出现紫色界面时快速按一次Esc以进入GNU GRUB"
echo "2.点击Ubuntu 高级选项"
echo "3.将光标以移动至Ubuntu, with Linux *-generic (recovery mode)，点击E"
echo "4.找到行linux，将recovery nomodeset dis_ucode_ldr替换为quiet splash rw init=/bin/bash"
echo "5.点击F10"
echo "6.passwd;sudo passwd;passwd [用户名];sudo passwd [用户名]"
echo "7.点击Ctrl+Alt+Del重启"
