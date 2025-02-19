#!/bin/bash
echo "登入校园网"
if [ "$(uname)" = "Linux" ]; then
    echo "curl -s \"http://p2.nju.edu.cn/api/portal/v1/login\" -d '{\"domain\":\"default\",\"username\":\"用户名\",\"password\":\"密码\"}'"
else
    echo "curl -s \"http://p2.nju.edu.cn/api/portal/v1/login\" -d \"{\\\"domain\\\":\\\"default\\\",\\\"username\\\":\\\"用户名\\\",\\\"password\\\":\\\"密码\\\"}\""
fi
echo "登出校园网"
echo "curl -s \"http://p2.nju.edu.cn/portal_io/logout\""
