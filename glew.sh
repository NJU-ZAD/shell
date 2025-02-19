#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
version=1.10
echo "https://sourceforge.net/projects/glew/files/glew/${version}.0/"
name=glew-${version}.0
error=1
function check_tgz() {
    if [ ! -f "./$name.tgz" ]; then
        echo "在shell/中没有找到$name.tgz"
        exit 1
    fi
}
function ln_lib() {
    sudo ln -s /usr/lib64/libGLEW.so /usr/lib/libGLEW.so
    sudo ln -s /usr/lib64/libGLEWmx.so /usr/lib/libGLEWmx.so
    sudo ln -s /usr/lib64/libGLEW.so.${version} /usr/lib/libGLEW.so.${version}
    sudo ln -s /usr/lib64/libGLEWmx.so.${version} /usr/lib/libGLEWmx.so.${version}
    sudo ln -s /usr/lib64/libGLEW.so.${version}.0 /usr/lib/libGLEW.so.${version}.0
    sudo ln -s /usr/lib64/libGLEWmx.so.${version}.0 /usr/lib/libGLEWmx.so.${version}.0
    sudo ln -s /usr/lib64/libGLEW.a /usr/lib/libGLEW.a
    sudo ln -s /usr/lib64/libGLEWmx.a /usr/lib/libGLEWmx.a
}
if [ -n "$1" ]; then
    if [ $1 = "64" ]; then
        error=0
        echo "安装64位GLEW ${version}..."
        check_tgz
        sudo apt-get install libxmu-dev libgl-dev libxi-dev libxmu-headers gcc-multilib -y
        tar -xf $name.tgz
        cd $name
        make
        sudo make install
        cd ..
        rm -rf $name
        ln_lib
        sudo ldconfig
    elif [ $1 = "32" ]; then
        error=0
        echo "安装32位GLEW ${version}..."
        check_tgz
        sudo apt-get install libxmu-dev:i386 libgl-dev:i386 libxi-dev:i386 libxmu-headers gcc-multilib -y
        tar -xf $name.tgz
        cd $name
        sed -i "s/CFLAGS = \$(OPT) \$(WARN) \$(INCLUDE) \$(CFLAGS.EXTRA)/CFLAGS = \$(OPT) \$(WARN) \$(INCLUDE) \$(CFLAGS.EXTRA) -m32/g" Makefile
        sed -i "s/LIB.LDFLAGS        := \$(LDFLAGS.EXTRA) \$(LDFLAGS.GL)/LIB.LDFLAGS        := \$(LDFLAGS.EXTRA) \$(LDFLAGS.GL) -m32/g" Makefile
        make
        sudo make install
        cd ..
        rm -rf $name
        ln_lib
        sudo ldconfig
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载GLEW ${version}..."
        sudo apt-get remove --purge libxmu-dev:i386 libgl-dev:i386 libxi-dev:i386 libxmu-headers -y
        sudo apt-get remove --purge libxmu-dev libxi-dev -y
        sudo rm -f /usr/include/GL/wglew.h
        sudo rm -f /usr/include/GL/glew.h
        sudo rm -f /usr/include/GL/glxew.h
        sudo rm -f /usr/lib/libGLEW.so /usr/lib/libGLEWmx.so
        sudo rm -f /usr/lib/libGLEW.so.${version} /usr/lib/libGLEWmx.so.${version}
        sudo rm -f /usr/lib/libGLEW.so.${version}.0 /usr/lib/libGLEWmx.so.${version}.0
        sudo rm -f /usr/lib/libGLEW.a /usr/lib/libGLEWmx.a
        sudo rm -f /usr/lib64/libGLEW.so /usr/lib64/libGLEWmx.so
        sudo rm -f /usr/lib64/libGLEW.so.${version} /usr/lib64/libGLEWmx.so.${version}
        sudo rm -f /usr/lib64/libGLEW.so.${version}.0 /usr/lib64/libGLEWmx.so.${version}.0
        sudo rm -f /usr/lib64/libGLEW.a /usr/lib64/libGLEWmx.a
        sudo rm -f /usr/bin/glewinfo /usr/bin/visualinfo
        sudo ldconfig
    fi
fi
if [ $error = "1" ]; then
    echo "./glew.sh 64	安装64位GLEW ${version}"
    echo "./glew.sh 32	安装32位GLEW ${version}"
    echo "./glew.sh 0	卸载64/32位GLEW ${version}"
fi
