#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
echo -e "\e[32m[Shell教程]\e[0m"
echo
echo "显示脚本执行过程"
echo "set -xe"
echo
echo "显示当前工作目录"
echo "currdir=\$(pwd)"
echo
echo "显示执行脚本的父目录"
echo "shdir=\$(cd \`dirname \$0\`; pwd)"
echo
echo "查看文件内容"
echo "cat 文件的完整路径"
echo
echo "下载 -t 0表示重试无数次 -c 表示允许断点续传"
echo "wget -t 0 -c \"URL\" -O ~/file_name"
echo
echo "输出用户信息"
echo "echo \${USER}"
echo "echo \${HOME}"
echo
echo "查看本机IP地址"
echo "echo \$(ifconfig|grep -E \"broadcast|广播\")"
echo "echo \$(ifconfig|grep -E \"<link>|Scope:Link\")"
echo
echo "判断文件/文件夹/软链接是否存在"
echo "if [ ! -f/-d/-h \"\${HOME}/name\" ]"
echo "then"
echo "	echo \"不存在\""
echo "else"
echo "	echo \"存在\""
echo "fi"
echo
echo "判断x是否等于0（不等于-ne）（大于-gt）（小于-lt）（大于等于-ge）（小于等于-le）"
echo "if [ \$x -eq 0 ]"
echo "then"
echo " 	echo \"等于\""
echo "else"
echo "	echo \"不等于\""
echo "fi"
echo
echo "向文件中添加新的一行"
echo "sed -i '\$a 添加的内容' name"
echo "向文件中添加新的一行（支持变量引用）"
echo "abc=123;sed -i \"\\\$a 添加的内容\$abc\" name"
echo
echo "输出内容到文件（清空模式）"
echo "echo \"content\"> name"
echo "sudo sh -c 'echo \"content\"> name'"
echo
echo "输出内容到文件（追加模式）"
echo "echo \"content\">> name"
echo "sudo sh -c 'echo \"content\">> name'"
echo
echo "输出更多内容到文件"
echo "cat > file_name << END_TEXT"
echo "文件内容"
echo "END_TEXT"
echo
echo "shell多行注释"
echo "<<'COMMENT'"
echo "注释内容"
echo "COMMENT"
echo
echo "暂停回车键继续"
echo "read -p \"按回车键继续...\""
echo
echo "自动输入shell中的输入"
echo "read -p \"输入：\" input <<EOF"
echo "预定的输入值"
echo "EOF"
echo "echo \$input"
echo
echo "挂载镜像文件"
echo "sudo mount -o loop file.iso /mnt"
echo "cd /mnt"
echo "sudo umount /mnt"
echo
echo "Linux下基于file协议通过网络或浏览器访问本地目录"
echo "file://${HOME}/"
echo "file://+目录的完整路径"
echo
echo "查找特定字符串在文件中的出现的次数"
echo "result=\$(grep -c \"string\" ~/filename)"
echo "echo \$result"
echo
echo "遍历数组"
echo "sudo touch ~/test.txt"
echo "array=(A B C D E)"
echo "for i in {0..4}"
echo "do"
echo "	echo \${array[i]}"
echo "	sudo sh -c 'echo \"'\${array[i]}'\"> ~/test.txt'"
echo "done"
echo
echo "循环输入判断"
echo "while :; do"
echo "	read -p \"是否继续循环？(Y/n)\" binary"
echo "	if [ \"\$binary\" = \"y\" ] || [ \"\$binary\" = \"Y\" ]"
echo "	then"
echo "	 	echo \"继续\""
echo "	elif [ \"\$binary\" = \"n\" ] || [ \"\$binary\" = \"N\" ]"
echo "	then"
echo "		break"
echo "	else"
echo "		echo \"输入错误\""
echo "	fi"
echo "done"
echo
echo "嵌套变量的使用"
echo "var_first=1"
echo "var_second=2"
echo "index=first"
echo "var_=var_\${index}"
echo "eval var=\$(echo \\$\$var_)"
echo "echo \$var_"
echo "echo \$var"
echo "index=second"
echo "var_=var_\${index}"
echo "eval var=\$(echo \\$\$var_)"
echo "echo \$var_"
echo "echo \$var"
echo
echo "比较两个文件是否相同"
echo "diff filename1 filename2"
echo
echo "找到\${HOME}/test.txt中含有key\no的一行"
echo "find=\$(grep -i \"key\\\\\\no\" \${HOME}/test.txt)"
echo "find=\$(grep -n \"key\\\\\\no\" \${HOME}/test.txt)"
echo "echo \$find"
echo
echo "将\${HOME}/test.txt中含有key\no的一行删除"
echo "sed -i '/key\\\no/d' \${HOME}/test.txt"
echo "sed -i \"/key\\\\\no/d\" \${HOME}/test.txt"
echo
echo "在\${HOME}/test.txt第2行后面插入key\no"
echo "sed -i '3i key\\\no' \${HOME}/test.txt"
echo "sed -i \"3i key\\\\\no\" \${HOME}/test.txt"
echo
echo "将\${HOME}/test.txt中的old替换为new"
echo "sed -i \"s#old#new#g\" \${HOME}/test.txt"
echo "sed -i \"s/old/new/g\" \${HOME}/test.txt"
echo
echo "将\${HOME}/test.txt中的第2行修改为hello"
echo "line=\"hello\""
echo "sed -i \"2c\${line}\" \${HOME}/test.txt"
echo
echo "sed命令中的\"和'有一定区别"
echo "\"会对引号包含的部分进行处理"
echo "'不会对引号包含的部分进行任何处理"
echo
echo "递归查找文件夹shell下所有包含\${HOME}或latex的文件"
echo "grep -r -E \"\\\\\\\${HOME}|latex\" \${HOME}/shell"
echo
echo "递归查找文件夹shell下所有包含\${HOME}和latex的文件"
echo "grep -r \"\\\\\\\${HOME}\" \${HOME}/shell | grep \"latex\""
echo
echo "获取字符串的最后一个字符"
echo "last_char=\${str: -1}"
echo
echo "var=\"123:abd:456\""
echo "删除:左边字符保留:右边字符"
echo "echo \"\${var#*:}\""
echo "echo \"\${var##*:}\""
echo "删除:右边字符保留:左边字符"
echo "echo \"\${var%:*}\""
echo "echo \"\${var%%:*}\""
echo
echo "根据网卡名称获取IPv4地址"
echo "inet=\$(ifconfig|grep -A 1 \"wlp2s0\")"
echo "OLD_IFS=\"\$IFS\""
echo "IFS=\" \""
echo "inets=(\$inet)"
echo "IFS=\"\$OLD_IFS\""
echo "let \"i=0\""
echo "for var in \${inets[@]}"
echo "do"
echo "    if [ \$var = \"inet\" ]"
echo "    then"
echo "        break"
echo "    fi"
echo "    let \"i=i+1\""
echo "done"
echo "let \"i=i+1\""
echo "echo \${inets[\$i]}"
echo
echo "读取文件第一行的内容"
echo "line=\$(head -n 1 \"/etc/issue\")"
echo "echo \$line"
echo
echo "读取文件第二行的内容"
echo "line=\$(sed -n 2p \"/etc/issue\")"
echo "echo \$line"
echo
echo "读取文件最后一行的内容"
echo "line=\$(tail -n 1 \"/etc/issue\")"
echo "echo \$line"
echo
echo "显示文件的1到3行的内容"
echo "sed -n '1,3p' ~/gurobi.lic"
echo "awk 'NR>=1&&NR<=3' ~/gurobi.lic"
echo
echo "去除字符串前后的空格"
echo "str=\$(echo \" string and space \" | awk '{gsub(/^\+|\+$/,\"\");print}')"
echo "echo \$str"
echo
echo "去除字符串所有的空格"
echo "str=\$(echo \" string and space \" | sed 's/ //g')"
echo "echo \$str"
echo
echo "将字符串中的old替换为new"
echo "str=\$(echo \"old string\" | sed 's/old/new/g')"
echo "echo \$str"
echo "oldv=\"oldstring\""
echo "newv=\"newstring\""
echo "str=\$(echo \"the oldstring\" | sed \"s/\$oldv/\$newv/g\")"
echo "echo \$str"
echo
echo "判断ABCD中是否包含BC"
echo "if [[ \"ABCD\" =~ \"BC\" ]]; then"
echo "    echo \"包含\""
echo "else"
echo "    echo \"不包含\""
echo "fi"
echo
echo "判断AB/CD中是否包含/"
echo "res=\$(echo \"AB/CD\" | grep \"/\")"
echo "echo \$res"
echo
echo "判断AB\CD中是否包含\\"
echo "res=\$(echo \"AB\CD\" | grep \"\\\\\\\\\")"
echo "echo \$res"
echo
echo "将字符串中所有单词的首字母大写"
echo "line=\"you are the best one\""
echo "line=\$(echo \"\$line\" | sed 's/\b[a-z]/\U&/g')"
echo "echo \$line"
echo
echo "删除字符串中st和=之间的内容（包括=）"
echo "line=\"wqst8e0-+=234\""
echo "line=\$(echo \"\$line\" | sed 's/st.*=/st/g')"
echo "echo \$line"
echo
echo "将Windows环境下GBK编码的文档转换为UTF8编码的文档"
echo "iconv -f gbk -t utf8 old > new"
