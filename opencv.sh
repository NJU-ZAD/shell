#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
# git clone https://github.com/opencv/opencv.git
# git clone https://github.com/opencv/opencv_contrib.git
# git clone https://github.com/opencv/opencv_extra.git
currdir=$(pwd)
ARCH=$(uname -m)
shell=$(env | grep SHELL=)
echo $shell
if [ $shell = "SHELL=/bin/bash" ]; then
    rc=.bashrc
else
    rc=.zshrc
fi
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ "$1" = "1" ]; then
        error=0
        echo "从APT安装OpenCV（不支持Conda）..."
        sudo apt update
        if [ "$ARCH" = "x86_64" ]; then
            sudo apt install libopencv-dev python3-opencv -y
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] || [ "$ARCH" = "armhf" ]; then
            sudo apt install libopencv-dev python-opencv -y
        fi
        python3 -c "import cv2; print(cv2.__version__)"
        echo "CudaEnabledDeviceCount"
        python3 -c "import cv2; print(cv2.cuda.getCudaEnabledDeviceCount())"
    elif [ "$1" = "2" ]; then
        error=0
        echo "为Conda安装OpenCV（不支持CUDA）..."
        conda install -c conda-forge opencv
        python3 -c "import cv2; print(cv2.__version__)"
        echo "CudaEnabledDeviceCount"
        python3 -c "import cv2; print(cv2.cuda.getCudaEnabledDeviceCount())"
    elif [ "$1" = "3" ]; then
        error=0
        echo "从源码安装OpenCV（支持CUDA）..."
        sudo apt-get install cmake unzip build-essential pkg-config python3-dev -y
        if [ "$ARCH" = "x86_64" ]; then
            sudo apt-get install libgtk-3-dev libeigen3-dev \
                libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
                libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
                gfortran openexr libatlas-base-dev python3-numpy \
                libtbb2 libtbb-dev libdc1394-22-dev libopenexr-dev \
                libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev -y
            prefix_path="/usr/lib/x86_64-linux-gnu"
        elif [ "$ARCH" = "aarch64" ]; then
            prefix_path="/usr/lib/aarch64-linux-gnu"
        fi
        cd ${HOME}
        array=(opencv opencv_contrib)
        for i in {0..1}; do
            name=${array[i]}
            # echo $name
            if [ ! -d "$name" ]; then
                if [ ! -f "${currdir}/$name.zip" ]; then
                    echo "正在从网络获取$name..."
                    curl --head --max-time 3 --silent --output /dev/null --fail "www.google.com"
                    if [ $? -ne 0 ]; then
                        read -p "接下来需要GRACE"
                    fi
                    git clone https://github.com/opencv/$name.git
                else
                    echo "正在解压$name..."
                    unzip -q "${currdir}/$name.zip"
                fi
            else
                echo "已经获取本地$name"
            fi
            cd $name
            git pull
            cd ..
        done
        cd opencv
        rm -rf build
        mkdir build
        cd build
        if [ -z "$CONDA_DEFAULT_ENV" ]; then
            sudo apt-get install python3 -y
            python3 -m pip install --upgrade pip
            pip3 install numpy
            install_path=/usr/local
            python_libs=${prefix_path}/libpython3*so
        else
            conda update python -y
            conda install numpy -y
            install_path=$CONDA_PREFIX
            if [ -f "${install_path}/lib/libtinfo.so.6" ]; then
                mv ${install_path}/lib/libtinfo.so.6 ${install_path}/lib/libtinfo.so.6.bak
            fi
            python_libs=${install_path}/lib/libpython3*so
        fi
        curl --head --max-time 3 --silent --output /dev/null --fail "www.google.com"
        if [ $? -ne 0 ]; then
            read -p "接下来需要GRACE"
        fi
        cmake -D CMAKE_BUILD_TYPE=RELEASE \
            -D CMAKE_PREFIX_PATH=${prefix_path} \
            -D CMAKE_INSTALL_PREFIX=${install_path} \
            -D PYTHON_LIBRARY=${python_libs} \
            -D PYTHON_EXECUTABLE=$(which python3) \
            -D OPENCV_GENERATE_PKGCONFIG=ON \
            -D OPENCV_EXTRA_MODULES_PATH=${HOME}/opencv_contrib/modules \
            -D WITH_CUDA=ON \
            -D WITH_CUDNN=OFF \
            -D WITH_NVCUVID=OFF \
            -D WITH_NVCUVENC=OFF \
            -D WITH_OBSENSOR=OFF \
            -D BUILD_opencv_videoio=OFF \
            -D BUILD_opencv_cudaarithm=OFF \
            -D BUILD_opencv_cudalegacy=OFF \
            -D BUILD_opencv_photo=OFF \
            -D BUILD_opencv_gapi=OFF ..
        make -j$(nproc)
        if [ -z "$CONDA_DEFAULT_ENV" ]; then
            sudo make install
            sudo ldconfig
            pkg-config --modversion opencv4
            cp -r /usr/local/lib/python3.*/site-packages/cv2 ${HOME}/.local/lib/python3.*/site-packages/
        else
            make install
            if [ "$ARCH" = "x86_64" ]; then
                export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libffi.so.7
                if [ $(grep -c "export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libffi.so.7" ${HOME}/$rc) -eq 0 ]; then
                    echo "export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libffi.so.7" >>${HOME}/$rc
                fi
                echo "在新终端中执行以下Python代码来测试"
            fi
            if [ -f "${install_path}/lib/libtinfo.so.6.bak" ]; then
                mv ${install_path}/lib/libtinfo.so.6.bak ${install_path}/lib/libtinfo.so.6
            fi
        fi
        echo "import cv2; print(cv2.__version__)"
        python3 -c "import cv2; print(cv2.__version__)"
        echo "import cv2; print(cv2.cuda.getCudaEnabledDeviceCount())"
        python3 -c "import cv2; print(cv2.cuda.getCudaEnabledDeviceCount())"
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载所有OpenCV..."
        if [ "$ARCH" = "x86_64" ]; then
            sudo apt-get --purge remove libopencv-dev python3-opencv -y
            sudo apt-get --purge remove cmake libgtk-3-dev libeigen3-dev \
                libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
                libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
                gfortran openexr libatlas-base-dev python3-numpy \
                libtbb2 libtbb-dev libdc1394-22-dev libopenexr-dev \
                libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev -y
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] || [ "$ARCH" = "armhf" ]; then
            if dpkg -l | grep -q nvidia-jetpack; then
                sudo apt-get --purge remove python-opencv -y
            else
                sudo apt-get --purge remove libopencv-dev python-opencv -y
            fi
        fi
        conda remove opencv
        pip3 uninstall opencv-python
        if [ ! -d "${HOME}/opencv/build" ]; then
            echo "没有找到目录${HOME}/opencv/build"
            echo "无法从源码卸载OpenCV"
        else
            cd ${HOME}/opencv/build
            sudo make uninstall
            sudo ldconfig
        fi
        local_path=$(echo ${HOME}/.local/lib/python3.*/site-packages/cv2)
        rm -rf ${local_path}
        conda_path=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
        rm -rf ${conda_path}/cv2
        sudo rm -rf ${HOME}/opencv/build /usr/local/include/opencv4
        sed -i "/libffi.so.7/d" ${HOME}/$rc
    fi
fi
if [ $error = "1" ]; then
    echo "./opencv.sh 1	从APT安装OpenCV（不支持Conda）"
    echo "./opencv.sh 2	为Conda安装OpenCV（不支持CUDA）"
    echo "./opencv.sh 3	从源码安装OpenCV（支持CUDA），在编译时默认使用APT安装的Python版本除非Conda环境已经激活"
    echo "./opencv.sh 0	卸载所有OpenCV"
fi
