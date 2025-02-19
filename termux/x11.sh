#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
pkg install x11-repo termux-x11-nightly xfce4 vlc
pip install ffmpeg-python pillow
termux-x11 :1 -xstartup "dbus-launch --exit-with-session xfce4-session" &
