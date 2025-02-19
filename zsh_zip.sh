#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
array=(ohmyzsh zsh-autosuggestions zsh-syntax-highlighting fzf)
curl --head --max-time 3 --silent --output /dev/null --fail "www.google.com"
if [ $? -eq 0 ]; then
    for i in {0..3}; do
        zip_name=${array[i]}
        echo ${zip_name}
        if [ -f "${zip_name}.zip" ] || [ -d "${zip_name}" ]; then
            if [ ! -d "${zip_name}" ]; then
                unzip -q ${zip_name}.zip
            fi
            rm -rf ${zip_name}.zip
            cd ${zip_name}
            git pull
            cd ..
            install_file="$zip_name/install"
            if [ "$zip_name" = "fzf" ]; then
                version=$(grep -oP 'version=\K[0-9][0-9.]*' "$install_file" | head -n 1)
                echo $version
                if [ -z "$version" ]; then
                    echo "Error: Version not found in $install_file"
                    exit 1
                fi
                rm -f fzf-*-linux_amd64.tar.gz
                download_url=$(grep -o 'url=https://github.com/junegunn.*\$version' "$install_file" | sed 's/^url=//; s/\$version//')
                url="${download_url}${version}/fzf-${version}-linux_amd64.tar.gz"
                curl -L -o "fzf-$version-linux_amd64.tar.gz" "$url"
            fi
            zip -q -r ${zip_name}.zip ${zip_name}/
            rm -rf ${zip_name}/
        fi
    done
    mkdir MesloLGS-NF
    cd MesloLGS-NF
    font_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
    curl -Lk "$font_url/MesloLGS%20NF%20Regular.ttf" --output "MesloLGS NF Regular.ttf"
    curl -Lk "$font_url/MesloLGS%20NF%20Bold.ttf" --output "MesloLGS NF Bold.ttf"
    curl -Lk "$font_url/MesloLGS%20NF%20Italic.ttf" --output "MesloLGS NF Italic.ttf"
    curl -Lk "$font_url/MesloLGS%20NF%20Bold%20Italic.ttf" --output "MesloLGS NF Bold Italic.ttf"
    cd ..
    if [[ $(ls -A MesloLGS-NF | wc -l) -eq 0 ]]; then
        echo "下载失败，请再试一遍"
    else
        rm -rf MesloLGS-NF.zip
        zip -q -r MesloLGS-NF.zip MesloLGS-NF
    fi
    rm -rf MesloLGS-NF
else
    echo "需要GRACE"
fi
