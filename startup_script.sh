read -p "请输入开机自启脚本的绝对路径" script_path
if [ -f "$script_path" ]; then
    script_name=${script_path##*/}
    script_name="${script_name%.*}"
    # echo "$script_name"
    cat >$script_name.service <<END_TEXT
[Unit]
Description=$script_name
After=network.target

[Service]
ExecStart=$script_path

[Install]
WantedBy=default.target
END_TEXT
    service_path=/etc/systemd/system/$script_name.service
    if [ -f "$service_path" ]; then
        echo "服务${service_path}已经存在"
        read -p "是否删除该服务(Y/n)" reply
        if [ "$reply" = "Y" ] || [ "$reply" = "y" ]; then
            sudo rm -rf $service_path
        else
            echo "未删除服务${service_path}，结束配置"
            exit
        fi
    fi
    sudo mv $script_name.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable $script_name.service
    sudo systemctl start $script_name.service
else
    echo "不存在路径为${script_path}的脚本"
fi
