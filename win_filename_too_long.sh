#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
git config --global core.longpaths true
