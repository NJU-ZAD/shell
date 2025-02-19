#!/bin/bash
# https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/
MIRRORS=(
    "mirrors.nju.edu.cn"
    "mirrors.tuna.tsinghua.edu.cn"
    "mirrors.aliyun.com"
    "mirrors.ustc.edu.cn"
)

read -p "是否测试国内源的下载速度？Y/n：" -n 1 answer
echo
if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
    curl -o /dev/null -s -w "1) ${MIRRORS[0]} "%{speed_download}"\n" "https://${MIRRORS[0]}"
    curl -o /dev/null -s -w "2) ${MIRRORS[1]} "%{speed_download}"\n" "https://${MIRRORS[1]}"
    curl -o /dev/null -s -w "3) ${MIRRORS[2]} "%{speed_download}"\n" "https://${MIRRORS[2]}"
    curl -o /dev/null -s -w "4) ${MIRRORS[3]} "%{speed_download}"\n" "https://${MIRRORS[3]}"
else
    echo "1) ${MIRRORS[0]}"
    echo "2) ${MIRRORS[1]}"
    echo "3) ${MIRRORS[2]}"
    echo "4) ${MIRRORS[3]}"
fi

read -p "请输入数字 (1, 2, 3, 4): " -n 1 CHOICE
echo
if ! [[ "$CHOICE" =~ ^[1-4]$ ]]; then
    echo "输入无效，请输入1、2、3或4."
    exit 1
fi

ARCH=$(uname -m)
TARGET="ubuntu"
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] || [ "$ARCH" = "armhf" ]; then
    TARGET="ubuntu-ports"
fi
MIRROR="${MIRRORS[$((CHOICE - 1))]}"
VERSION=$(lsb_release -rs)
replace_sources() {
    local FILE=$1
    sudo sed -i "s|http://[^/]\+/${TARGET}/|http://${MIRROR}/${TARGET}/|g" $FILE
    sudo sed -i "s|https://[^/]\+/${TARGET}/|https://${MIRROR}/${TARGET}/|g" $FILE
}
if [[ "$VERSION" < "24.04" ]]; then
    replace_sources "/etc/apt/sources.list"
    echo "已将/etc/apt/sources.list中的镜像替换为 ${MIRROR}"
else
    replace_sources "/etc/apt/sources.list.d/ubuntu.sources"
    echo "已将/etc/apt/sources.list.d/ubuntu.sources中的镜像替换为 ${MIRROR}"
fi

sudo apt update
