#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
currdir=$(pwd)
font_dir="$HOME/.local/share/fonts"
# https://ohmyz.sh/#install
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        echo "安装zsh..."
        sudo apt-get install zsh -y
        mkdir -p $font_dir
        echo -e "\e[31m安装完成后请打开新终端\e[0m"
        curl --head --max-time 3 --silent --output /dev/null --fail "www.google.com"
        if [ $? -eq 0 ]; then
            font_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
            curl -Lk "$font_url/MesloLGS%20NF%20Regular.ttf" --output $font_dir/"MesloLGS NF Regular.ttf"
            curl -Lk "$font_url/MesloLGS%20NF%20Bold.ttf" --output $font_dir/"MesloLGS NF Bold.ttf"
            curl -Lk "$font_url/MesloLGS%20NF%20Italic.ttf" --output $font_dir/"MesloLGS NF Italic.ttf"
            curl -Lk "$font_url/MesloLGS%20NF%20Bold%20Italic.ttf" --output $font_dir/"MesloLGS NF Bold Italic.ttf"
            sudo fc-cache -fv
            rm -rf ${HOME}/.oh-my-zsh
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        else
            if [ ! -f "ohmyzsh.zip" ]; then
                echo "在shell/中没有找到ohmyzsh.zip"
                exit
            fi
            if [ ! -f "MesloLGS-NF.zip" ]; then
                echo "在shell/中没有找到MesloLGS-NF.zip"
                exit
            fi
            rm -rf ${HOME}/.oh-my-zsh
            unzip MesloLGS-NF.zip
            cd MesloLGS-NF/
            cp *.ttf $font_dir
            sudo fc-cache -fv
            cd ..
            rm -rf MesloLGS-NF
            unzip ohmyzsh.zip
            mv ohmyzsh ${HOME}/.oh-my-zsh
            cd $currdir
            # https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
            # 修改install.sh 注释[Manual clone with git代码块]和[执行setup_ohmyzsh前的exit 1]
            ./_zsh_install.sh
        fi
        zsh --version
    elif [ $1 = "+" ]; then
        error=0
        echo "配置zsh..."
        zsh_autosuggestions_dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        zsh_syntax_highlighting=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        curl --head --max-time 3 --silent --output /dev/null --fail "www.google.com"
        if [ $? -eq 0 ]; then
            if [ ! -d "$zsh_autosuggestions_dir" ]; then
                git clone https://github.com/zsh-users/zsh-autosuggestions ${zsh_autosuggestions_dir}
            else
                cd $zsh_autosuggestions_dir
                git pull
                cd $currdir
            fi
            if [ ! -d "$zsh_syntax_highlighting" ]; then
                git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${zsh_syntax_highlighting}
            else
                cd $zsh_syntax_highlighting
                git pull
                cd $currdir
            fi
            rm -rf ${HOME}/.fzf
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        else
            if [ ! -f "zsh-autosuggestions.zip" ]; then
                echo "在shell/中没有找到zsh-autosuggestions.zip"
                exit
            fi
            if [ ! -f "zsh-syntax-highlighting.zip" ]; then
                echo "在shell/中没有找到zsh-syntax-highlighting.zip"
                exit
            fi
            if [ ! -f "fzf.zip" ]; then
                echo "在shell/中没有找到fzf.zip"
                exit
            fi
            if ! ls fzf-*-linux_amd64.tar.gz 1>/dev/null 2>&1; then
                echo "在shell/中没有找到形如fzf-*-linux_amd64.tar.gz的文件"
                exit
            fi
            rm -rf ${HOME}/.fzf
            unzip zsh-autosuggestions.zip
            rm -rf $zsh_autosuggestions_dir
            mv zsh-autosuggestions $zsh_autosuggestions_dir
            unzip zsh-syntax-highlighting.zip
            rm -rf $zsh_syntax_highlighting
            mv zsh-syntax-highlighting $zsh_syntax_highlighting
            unzip fzf.zip
            mv fzf ${HOME}/.fzf
            tar -xf fzf-*-linux_amd64.tar.gz
            mv fzf ${HOME}/.fzf/bin/fzf
        fi
        ~/.fzf/install
        sed -i '/plugins=(git)/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' ${HOME}/.zshrc
        read -p "是否使用powerlevel10k主题(Y/n)" reply
        if [ "$reply" = "Y" ] || [ "$reply" = "y" ]; then
            powerlevel10k_dir=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
            curl --head --max-time 3 --silent --output /dev/null --fail "www.baidu.com"
            if [ $? -eq 0 ]; then
                if [ ! -d "$powerlevel10k_dir" ]; then
                    git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git $powerlevel10k_dir
                else
                    cd $powerlevel10k_dir
                    git pull
                    cd $currdir
                fi
            else
                echo "互联网连接存在问题"
                exit
            fi
            sed -i 's#ZSH_THEME="[^"]*"#ZSH_THEME="powerlevel10k/powerlevel10k"#g' ${HOME}/.zshrc
            if ! grep -q 'p10k.zsh' ${HOME}/.zshrc; then
                echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >>${HOME}/.zshrc
            fi
            echo "1.配置文件首选项-未命名-文本-[打勾]自定义字体-MesloLGS NF Regular-11"
            echo "2.配置文件首选项-未命名-颜色-[去勾]使用系统主题的颜色-内置方案-Tango暗色(文本和背景颜色)和Tango(调色板)"
        else
            echo "RPROMPT='[%*]'" >>${HOME}/.oh-my-zsh/themes/lukerandall.zsh-theme
            sed -i 's#ZSH_THEME="[^"]*"#ZSH_THEME="lukerandall"#g' ${HOME}/.zshrc
        fi
        if [ -d "${HOME}/anaconda3" ]; then
            ${HOME}/anaconda3/bin/conda init bash
            ${HOME}/anaconda3/bin/conda init zsh
            sed -i '/export HOST/d' ${HOME}/.zshrc
            echo "export HOST=\$(hostname)" >>${HOME}/.zshrc
        fi
        echo -e "\e[31m打开新终端使配置生效\e[0m"
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载zsh..."
        read -p "按回车键继续..."
        rm -rf $font_dir/MesloLGS*
        sudo fc-cache -fv
        # whereis zsh
        # zsh: /usr/share/zsh
        if [ -d "${HOME}/.oh-my-zsh" ]; then
            chmod +x ${HOME}/.oh-my-zsh/tools/uninstall.sh
            ${HOME}/.oh-my-zsh/tools/uninstall.sh
        fi
        sudo apt-get remove --purge zsh -y
        sudo apt-get autoremove
        rm -rf "${HOME}/.oh-my-zsh" ${HOME}/.zshrc
        echo "配置文件首选项-未命名-文本-[去勾]自定义字体"
        echo -e "\e[31m打开新终端使卸载生效\e[0m"
    fi
fi
if [ $error = "1" ]; then
    echo "./zsh.sh 1	安装zsh"
    echo "./zsh.sh +	配置zsh"
    echo "./zsh.sh 0	卸载zsh"
    echo "解决登陆界面用户未列出的问题"
    echo "sudo su;cd /var/lib/AccountsService/users;SystemAccount->false"
fi
