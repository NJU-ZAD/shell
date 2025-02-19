#!/bin/bash
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    os_type="cli-alpine-x64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    os_type="cli-alpine-arm64"
elif [ "$ARCH" = "armhf" ]; then
    os_type="cli-linux-armhf"
fi
cd ${HOME}
if [ ! -f "code" ]; then
    curl -Lk "https://code.visualstudio.com/sha/download?build=stable&os=${os_type}" --output vscode_cli.tar.gz
    tar -xf vscode_cli.tar.gz
    rm -rf vscode_cli.tar.gz
else
    chmod +x code
    ./code tunnel
fi
