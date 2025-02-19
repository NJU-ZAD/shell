#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        echo "安装VLC media player..."
        sudo apt-get install vlc -y
        echo "vlc -v"
        vlc -v
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载VLC media player..."
        sudo apt-get remove --purge vlc
    fi
fi
if [ $error = "1" ]; then
    echo "./vlc.sh 1	安装VLC media player"
    echo "./vlc.sh 0	卸载VLC media player"
fi
