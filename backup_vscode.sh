#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
# ${HOME}/.vscode/
# vscode.zip
# vscdoe/settings.json
# vscdoe/argv.json
# vscdoe/extensions/...
# vscdoe/TTF/FiraCode-Bold.ttf
# vscdoe/TTF/FiraCode-Light.ttf
# vscdoe/TTF/FiraCode-Medium.ttf
# vscdoe/TTF/FiraCode-Regular.ttf
# vscdoe/TTF/FiraCode-Retina.ttf

if [ -d "vscode/" ]; then
	sudo chown ${USER}: -R vscode/
	sudo rm -rf vscode/
fi
sudo mkdir vscode/
sudo cp ${HOME}/.config/Code/User/settings.json vscode/settings.json
sudo cp ${HOME}/.vscode/argv.json vscode/argv.json
sudo cp -r ${HOME}/.vscode/extensions vscode/
sudo mkdir vscode/TTF/
sudo cp ${HOME}/.local/share/fonts/FiraCode-Bold.ttf vscode/TTF/FiraCode-Bold.ttf
sudo cp ${HOME}/.local/share/fonts/FiraCode-Light.ttf vscode/TTF/FiraCode-Light.ttf
sudo cp ${HOME}/.local/share/fonts/FiraCode-Medium.ttf vscode/TTF/FiraCode-Medium.ttf
sudo cp ${HOME}/.local/share/fonts/FiraCode-Regular.ttf vscode/TTF/FiraCode-Regular.ttf
sudo cp ${HOME}/.local/share/fonts/FiraCode-Retina.ttf vscode/TTF/FiraCode-Retina.ttf
sudo chown ${USER}: -R vscode
zip -q -r vscode.zip vscode/
sudo rm -rf vscode/
echo
echo "已成功备份vscode的设置、字体和扩展等，保存在vscode.zip中！"
