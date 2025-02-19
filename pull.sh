#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
if [ ! -n "$1" ]; then
    error=0
    if [ ! -f "${HOME}/private-shell/gitee.txt" ]; then
        echo "${HOME}/private-shell/gitee.txt不存在！"
        echo "${HOME}/private-shell/gitee.txt第1行为邮箱"
        echo "${HOME}/private-shell/gitee.txt第2行为用户名"
        echo "${HOME}/private-shell/gitee.txt第3行为密码"
        exit
    fi
    Email=$(sed -n 1p "${HOME}/private-shell/gitee.txt")
    Username=$(sed -n 2p "${HOME}/private-shell/gitee.txt")
    Password=$(sed -n 3p "${HOME}/private-shell/gitee.txt")
elif [ -n "$1" ]; then
    if [ "$1" = "1" ]; then
        error=0
        if [ ! -f "${HOME}/private-shell/github.txt" ]; then
            echo "${HOME}/private-shell/github.txt不存在！"
            echo "${HOME}/private-shell/github.txt第1行为邮箱"
            echo "${HOME}/private-shell/github.txt第2行为用户名"
            echo "${HOME}/private-shell/github.txt第3行为个人访问令牌（PAT）"
            echo "关于个人访问令牌（PAT）"
            echo "https://docs.github.com/cn/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token"
            exit
        fi
        Email=$(sed -n 1p "${HOME}/private-shell/github.txt")
        Username=$(sed -n 2p "${HOME}/private-shell/github.txt")
        Password=$(sed -n 3p "${HOME}/private-shell/github.txt")
    elif [ "$1" = "0" ]; then
        error=0
    fi
fi
if [ $error -eq 0 ]; then
    echo "https://gitee.com/qqzad/shell.git"
    git pull
    cd ..
    echo "https://gitee.com/qqzad/reuse-code.git"
    if [ -d "reuse-code" ]; then
        echo "reuse-code"
        cd reuse-code
        git pull
        cd ..
    fi
    echo "https://gitee.com/qqzad/private-shell.git"
    if [ -d "private-shell" ]; then
        echo "private-shell"
        if [ "$1" = "0" ]; then
            cd private-shell
            git pull
            cd ..
        else
            cd private-shell
            expect <<EOF
spawn git pull
expect "Username"
send "$Username\n"
expect "Password"
send "$Password\n"
expect eof
EOF
            cd ..
        fi

    fi
    echo "https://gitee.com/qqzad/gpu-schedule.git"
    if [ -d "gpu-schedule" ]; then
        echo "gpu-schedule"
        if [ "$1" = "0" ]; then
            cd gpu-schedule
            git pull
            cd ..
        else
            cd gpu-schedule
            expect <<EOF
spawn git pull
expect "Username"
send "$Username\n"
expect "Password"
send "$Password\n"
expect eof
EOF
            cd ..
        fi
    fi
    echo "https://gitee.com/qqzad/edge-computing.git"
    if [ -d "edge-computing" ]; then
        echo "edge-computing"
        if [ "$1" = "0" ]; then
            cd edge-computing
            git pull
            cd ..
        else
            cd edge-computing
            expect <<EOF
spawn git pull
expect "Username"
send "$Username\n"
expect "Password"
send "$Password\n"
expect eof
EOF
            cd ..
        fi
    fi
    echo "https://gitee.com/qqzad/streamer.git"
    if [ -d "streamer" ]; then
        echo "streamer"
        if [ "$1" = "0" ]; then
            cd streamer
            git pull
            cd ..
        else
            cd streamer
            expect <<EOF
spawn git pull
expect "Username"
send "$Username\n"
expect "Password"
send "$Password\n"
expect eof
EOF
            cd ..
        fi
    fi
    echo "https://gitee.com/qqzad/crucio.git"
    if [ -d "crucio" ]; then
        echo "crucio"
        if [ "$1" = "0" ]; then
            cd crucio
            git pull
            cd ..
        else
            cd crucio
            expect <<EOF
spawn git pull
expect "Username"
send "$Username\n"
expect "Password"
send "$Password\n"
expect eof
EOF
            cd ..
        fi
    fi
    echo "https://gitee.com/qqzad/icoder.git"
    if [ -d "icoder" ]; then
        echo "icoder"
        if [ "$1" = "0" ]; then
            cd icoder
            git pull
            cd ..
        else
            cd icoder
            expect <<EOF
spawn git pull
expect "Username"
send "$Username\n"
expect "Password"
send "$Password\n"
expect eof
EOF
            cd ..
        fi
    fi
    echo "https://gitee.com/qqzad/mesh.git"
    if [ -d "mesh" ]; then
        echo "mesh"
        if [ "$1" = "0" ]; then
            cd mesh
            git pull
            cd ..
        else
            cd mesh
            expect <<EOF
spawn git pull
expect "Username"
send "$Username\n"
expect "Password"
send "$Password\n"
expect eof
EOF
            cd ..
        fi
    fi
fi
if [ $error -eq 1 ]; then
    echo "./pull.sh Gitee"
    echo "./pull.sh 1 GitHub"
    echo "./pull.sh 0 Windows"
fi
