#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
sudo apt-get install dos2unix -y
echo "dos2unix your_script.sh"
