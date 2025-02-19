#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
kernel_info=$(uname -a)
if [[ $kernel_info == *"tegra"* ]]; then
    sudo apt install nvidia-l4t-kernel-headers
else
    sudo apt-get install linux-headers-$(uname -r)
fi
sudo apt-get update -y
sudo apt-get upgrade -y
if [ -d "${HOME}/.oh-my-zsh" ]; then
    echo "omz update"
fi
./clear.sh
