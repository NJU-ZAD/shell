#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo -e "\e[32m[Git教程]\e[0m"
echo
echo "git clone的3种协议"
echo "git clone https://github.com/QQZAD/shell.git"
echo "git clone git://github.com/QQZAD/shell.git"
echo "git clone git@github.com:QQZAD/shell.git"
echo
echo "初始化git仓库"
echo "git init"
echo
echo "查看所有分支"
echo "git branch"
echo
echo "新建分支new"
echo "git branch new"
echo
echo "新建分支new并切换到该分支"
echo "git checkout -b new"
echo
echo "删除分支new"
echo "git branch -d new"
echo
echo "放弃所有未提交的修改"
echo "git checkout ."
echo
echo "切换到主分支"
echo "git checkout master"
echo
echo "将new分支合并到当前分支中"
echo "git merge new"
echo
echo "下载子模块"
echo "git submodule init"
echo "git submodule update"
echo
echo "删除git仓库"
echo "rm -rf .git .gitignore .gitmodules"
echo
echo "git的zip文件的网址"
echo "https://codeload.github.com/QQZAD/Computer-Network/zip/master"
echo
echo "Problem with the SSL CA cert (path? access rights?)"
echo "sudo apt-get install ca-certificates -y"
