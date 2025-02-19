#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
sudo apt-get install imagemagick -y
file_name=$(find ./ -name "*.png")
if [ -n "$file_name" ]; then
    old_string="<policy domain=\"coder\" rights=\"none\" pattern=\"EPS\" />"
    new_string="<policy domain=\"coder\" rights=\"read|write\" pattern=\"EPS\" />"
    sudo sed -i "s#$old_string#$new_string#g" /etc/ImageMagick-6/policy.xml
    # sudo gedit /etc/ImageMagick-6/policy.xml
    echo "将png图片转换为eps图片..."
    file_names=(${file_name//\ / })
    for i in "${!file_names[@]}"; do
        str_png=${file_names[i]}
        str_eps_=(${str_png//\./ })
        str_eps="."${str_eps_[0]}".eps"
        echo "find $str_png"
        convert $str_png $str_eps
        echo "generate $str_eps"
    done
else
    echo "No png!"
fi
