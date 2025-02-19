#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
sudo apt-get install pdftk -y
echo "在合并前应确保所有PDF的页面大小相同"
echo "注意：可以通过Microsoft Print to PDF实现PDF页面大小的调整（页面设置为A4纸）"
echo "pdftk 1.pdf 2.pdf 3.pdf cat output 0.pdf"
