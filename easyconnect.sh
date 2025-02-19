#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
if ! dpkg -l | grep -q curl; then
    sudo apt-get install curl -y
fi
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ "$1" = "1" ]; then
        error=0
        echo "安装Easy Connect..."
        exec=/usr/share/sangfor/EasyConnect/EasyConnect
        if [ -f "$exec" ]; then
            $exec
        else
            name=EasyConnect.deb
            if [ ! -f "./$name" ]; then
                echo "正在从网络获取$name"
                if [ "$1" = "1" ]; then
                    # https://vpn.nju.edu.cn/portal EasyConnect_x64
                    curl -Lk 'https://download.sangfor.com.cn/download/product/sslvpn/pkg/linux_767/EasyConnect_x64_7_6_7_3.deb' --output $name
                fi
                echo "已经获取本地$name"
            fi
            sudo dpkg -i $name
            sudo apt-get -y install -f
            sudo apt-get install libcanberra-gtk-module libcanberra-gtk3-module -y
            version=$(lsb_release -r | awk '{print $2}')
            case $version in
            "16.04" | "18.04")
                echo $version
                ;;
            "20.04" | "22.04" | "24.04")
                echo $version
                libs=$(ldd /usr/share/sangfor/EasyConnect/EasyConnect | grep pango | awk '{print $1}' | sed 's/\.so.*//')
                process_lib() {
                    base_lib_name=$1
                    # https://mirrors.nju.edu.cn/ubuntu/pool/main/p/pango1.0
                    version="0_1.40.14-1ubuntu0.1"
                    target="amd64"
                    deb_file="${base_lib_name}-${version}_${target}.deb"
                    url="https://mirrors.nju.edu.cn/ubuntu/pool/main/p/pango1.0/${deb_file}"
                    curl -o "$deb_file" "$url"
                    dpkg-deb -x "$deb_file" "${base_lib_name}_extracted"
                    sudo cp "${base_lib_name}_extracted/usr/lib/x86_64-linux-gnu"/* /usr/share/sangfor/EasyConnect/
                    rm -rf "$deb_file" "${base_lib_name}_extracted"
                }
                for lib in $libs; do
                    process_lib "$lib"
                done
                ;;
            *)
                echo "Unknown version"
                ;;
            esac
        fi
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载Easy Connect..."
        sudo dpkg --purge easyconnect
    fi
fi
if [ $error = "1" ]; then
    echo "./easyconnect.sh 1    安装Easy Connect"
    echo "./easyconnect.sh 0    卸载Easy Connect"
fi
