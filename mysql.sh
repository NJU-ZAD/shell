#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        echo "安装MySQL..."
        sudo apt-get install mysql-server libmysqlclient-dev -y
        sudo systemctl start mysql
        echo -e "\e[32m在接下来的sql中依次输入\e[0m"
        echo -e "\e[32mALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by '12345678';\e[0m"
        echo -e "\e[32mexit;\e[0m"
        sudo mysql
        sudo mysql_secure_installation
    elif [ $1 = "2" ]; then
        error=0
        echo "[连接MySQL]"
        echo "sudo systemctl start mysql"
        echo "sudo mysql -u root -p"
        echo
        echo "[数据库操作]"
        echo "show databases;"
        echo "create database database_test;"
        echo "drop database database_test;"
        echo "use database_test;"
        echo
        echo "[表操作]"
        echo "show tables;"
        echo "create table table_test(id bigint(20) not null, name varchar(20) not null);"
        echo "show columns from table_test;"
        echo "drop table table_test;"
        echo
        echo "[表项操作]"
        echo "insert into table_test(id,name) values(5,'name');"
        echo "update table_test set name='bob' where id=5;"
        echo "select * from table_test;"
        echo "delete from table_test where id=5;"
        echo "alter table table_test add (mark float not null, info text not null, age double not null);"
        echo "alter table table_test drop column name;"
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载MySQL..."
        sudo systemctl stop mysql
        sudo apt-get remove --purge mysql-server mysql-client mysql-common libmysqlclient-dev mysql-server-core-* mysql-client-core-*
        sudo rm -rf /etc/mysql /var/lib/mysql /var/log/mysql
        sudo apt autoremove
    fi
fi
if [ $error = "1" ]; then
    echo "./mysql.sh 1	安装MySQL"
    echo "./mysql.sh 2	使用MySQL"
    echo "./mysql.sh 0	卸载MySQL"
fi
