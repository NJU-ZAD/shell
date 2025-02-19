#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
# sdkmanager --list
big_ver=33
small_ver=$big_ver.0.2
function config_env_var() {
	shell=$(env | grep SHELL=)
	echo $shell
	if [ $shell = "SHELL=/bin/bash" ]; then
		rc=.bashrc
	else
		rc=.zshrc
	fi
	if [ $(grep -c "export ANDROID_HOME=\"$1\"" ${HOME}/$rc) -eq 0 ]; then
		echo "export ANDROID_HOME=\"$1\"" >>${HOME}/$rc
	fi
	if [ $(grep -c "export PATH=\"\$ANDROID_HOME/cmdline-tools/latest/bin:\$PATH\"" ${HOME}/$rc) -eq 0 ]; then
		echo "export PATH=\"\$ANDROID_HOME/cmdline-tools/latest/bin:\$PATH\"" >>${HOME}/$rc
	fi
	sed -i "/ANDROID_HOME\/build-tools/d" ${HOME}/$rc
	if [ $(grep -c "export PATH=\"\$ANDROID_HOME/build-tools/$small_ver:\$PATH\"" ${HOME}/$rc) -eq 0 ]; then
		echo "export PATH=\"\$ANDROID_HOME/build-tools/$small_ver:\$PATH\"" >>${HOME}/$rc
	fi
	# gedit ${HOME}/.bashrc
	# gedit ${HOME}/.zshrc
	if [ $shell = "SHELL=/bin/bash" ]; then
		gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
	else
		gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
	fi
}
sdk_path=${HOME}/android-sdk
if [ -n "$1" ] && [ ! -n "$2" ]; then
	if [ "$1" = "1" ]; then
		error=0
		echo "安装Android环境..."
		apktool_jar=apktool_2.8.0.jar
		if [ ! -f "$apktool_jar" ]; then
			echo "在shell中没有找到$apktool_jar"
			echo "访问 https://bitbucket.org/iBotPeaches/apktool/downloads/"
			exit
		else
			echo -e "\e[32m已经获取本地$apktool_jar\e[0m"
		fi
		apktool=raw.githubusercontent.com_iBotPeaches_Apktool_master_scripts_linux_apktool.txt
		if [ ! -f "$apktool" ]; then
			echo "在shell中没有找到$apktool"
			echo "访问 https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool"
			exit
		else
			echo -e "\e[32m已经获取本地$apktool\e[0m"
		fi
		studio=commandlinetools-linux-9477386_latest.zip
		if [ ! -f "$studio" ]; then
			echo "在shell中没有找到$studio"
			echo "访问 https://developer.android.com/studio"
			exit
		else
			echo -e "\e[32m已经获取本地$studio\e[0m"
		fi
		./java.sh 1
		sudo apt install apktool -y
		sudo rm -rf /usr/local/bin/apktool.jar
		sudo cp $apktool_jar /usr/local/bin/apktool.jar
		sudo chmod +x /usr/local/bin/apktool.jar
		sudo rm -rf /usr/local/bin/apktool
		sudo cp $apktool /usr/local/bin/apktool
		sudo chmod +x /usr/local/bin/apktool

		if [ ! -d "cmdline-tools" ]; then
			unzip $studio
		fi
		if [ ! -d "$sdk_path" ]; then
			sudo mkdir $sdk_path
		fi
		if [ ! -d "$sdk_path/cmdline-tools" ]; then
			sudo mkdir $sdk_path/cmdline-tools
		fi
		sudo rm -rf $sdk_path/cmdline-tools/latest
		sudo mv cmdline-tools $sdk_path/cmdline-tools/latest
		config_env_var $sdk_path
		sudo chown ${USER}: -R $sdk_path
		sudo rm -rf $sdk_path/platforms $sdk_path/build-tools
		$sdk_path/cmdline-tools/latest/bin/sdkmanager \
			"platform-tools" "platforms;android-$big_ver" "build-tools;$small_ver"
		if [ ! -f "$sdk_path/licenses/person.keystore" ]; then
			keytool -genkeypair -v -alias person -keystore $sdk_path/licenses/person.keystore -validity 10000
		fi
		echo "apktool -version"
		apktool -version
		echo -e "\e[31m在新终端中运行sdkmanager --version\e[0m"
	elif [ "$1" = "2" ]; then
		error=0
		echo "签名并对齐apk文件..."
		files=($(find -name "*.apk"))
		for file in "${files[@]}"; do
			echo "处理$file"
			jarsigner -verbose -keystore $sdk_path/licenses/person.keystore \
				$file person
			zipalign -v 4 $file "${file%.*}.signed.apk"
			rm -rf $file
		done
	elif [ "$1" = "0" ]; then
		error=0
		echo "卸载Android环境..."
		sudo apt remove --purge apktool -y
		sudo rm -rf /usr/local/bin/apktool.jar /usr/local/bin/apktool $sdk_path

		shell=$(env | grep SHELL=)
		if [ $shell = "SHELL=/bin/bash" ]; then
			rc=.bashrc
		else
			rc=.zshrc
		fi
		sed -i "/ANDROID_HOME/d" ${HOME}/$rc
		if [ $shell = "SHELL=/bin/bash" ]; then
			gnome-terminal -- /bin/sh -c 'source ${HOME}/$rc;exit'
		else
			gnome-terminal -- /bin/zsh -c 'source ${HOME}/$rc;exit'
		fi
	fi
fi
if [ $error -eq 1 ]; then
	echo "./android.sh 1 安装Android环境"
	echo "./android.sh 2 签名并对齐apk文件"
	echo "./android.sh 0 卸载Android环境"
fi
