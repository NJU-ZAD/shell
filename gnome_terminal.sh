#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
currdir=$(pwd)
echo "启动bash终端"
echo "gnome-terminal -- /bin/sh -c 'echo \"test\";sleep 10;exec bash'"
echo "gnome-terminal -- /bin/sh -c ./shname.sh"
echo "启动zsh终端"
echo "gnome-terminal -- /bin/zsh -c 'echo \"test\";sleep 10;exec zsh'"
echo "gnome-terminal -- /bin/zsh -c ./shname.sh"
gnome-terminal -- /bin/zsh -c 'cd $0;echo "start1";sleep 10;echo "end1";exec zsh' "$currdir"
gnome-terminal -- /bin/zsh -c 'cd $0;echo "start2";sleep 10;echo "end2";exec zsh' "$currdir"
gnome-terminal -- /bin/zsh -c 'cd $0;echo "start3";sleep 10;echo "end3";exec zsh' "$currdir"
