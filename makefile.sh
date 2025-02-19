#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
sudo apt-get install make -y
read -p "选择编程语言(1-C/2-C++)：" answer
case $answer in
1)
    echo "已选择C语言"
    language="C"
    ;;
2)
    echo "已选择C++语言"
    language="C++"
    ;;
*)
    echo "输入错误,已选择C语言"
    language="C"
    answer=1
    ;;
esac
project_name="TestProject"
echo "让我们通过一个$language语言项目实例来了解Makefile"
echo "正在生成项目文件夹$project_name..."
if [ -d "${HOME}/$project_name/" ]; then
    sudo rm -rf ${HOME}/$project_name/
fi
sudo mkdir ${HOME}/$project_name/
sudo mkdir ${HOME}/$project_name/include/
sudo chown ${USER}: -R ${HOME}/$project_name/
cd ${HOME}/$project_name/
if [ $answer -eq 1 ]; then
    # Makefile
    cat >Makefile <<END_TEXT
cc = gcc
prom = main
inc = include/
deps = \$(shell find ./ -name "*.h")
src = \$(shell find ./ -name "*.c")
obj = \$(src:%.c=%.o)
libs = -lm -lpthread
\$(prom): \$(obj)
	\$(cc) -std=c11 -o \$(prom) \$(obj) \$(libs)
%.o: %.c \$(deps)
	\$(cc) -std=c11 -c \$< -o \$@ -I \$(inc)
run: \$(prom)
	./\$(prom)
clean:
	rm -rf \$(prom) \$(obj)
END_TEXT
    # main.h
    cat >include/main.h <<END_TEXT
//main.h
#include <stdio.h>
#include "sin_value.h"
#include "cos_value.h"
#include "tan_value.h"
#include "multi_thread.h"
END_TEXT
    # main.c
    cat >main.c <<END_TEXT
//main.c
#include "main.h"
double pi = 3.1415926535898;
int main()
{
    double angle;
    printf("输入一个度数：");
    scanf("%lf", &angle);
    sin_value(angle);
    cos_value(angle);
    tan_value(angle);
    multi_thread();
    return 0;
}
END_TEXT
    # sin_value.h
    cat >include/sin_value.h <<END_TEXT
//sin_value.h
void sin_value(double);
END_TEXT
    # sin_value.c
    cat >sin_value.c <<END_TEXT
//sin_value.c
#include <stdio.h>
#include <math.h>
extern double pi;
void sin_value(double angle)
{
    printf("The sin %lf is %lf\n", angle, sin(angle / 180.0 * pi));
}
END_TEXT
    # cos_value.h
    cat >include/cos_value.h <<END_TEXT
//cos_value.h
void cos_value(double);
END_TEXT
    # cos_value.c
    cat >cos_value.c <<END_TEXT
//cos_value.c
#include <stdio.h>
#include <math.h>
extern double pi;
void cos_value(double angle)
{
    printf("The cos %lf is %lf\n", angle, cos(angle / 180.0 * pi));
}
END_TEXT
    # tan_value.h
    cat >include/tan_value.h <<END_TEXT
//tan_value.h
void tan_value(double);
END_TEXT
    # tan_value.c
    cat >tan_value.c <<END_TEXT
//tan_value.c
#include <stdio.h>
#include <math.h>
extern double pi;
void tan_value(double angle)
{
    printf("The tan %lf is %lf\n", angle, tan(angle / 180.0 * pi));
}
END_TEXT
    # multi_thread.h
    cat >include/multi_thread.h <<END_TEXT
//multi_thread.h
void multi_thread();
END_TEXT
    # multi_thread.c
    cat >multi_thread.c <<END_TEXT
//multi_thread.c
#include <stdio.h>
#include <pthread.h>
#include <time.h>
#include <string.h>

pthread_t thread[2];
pthread_mutex_t mut;
int MAX;
int number = 0;
int i;
int sleep();
int rand();
void *thread1()
{
    for (i = 0; i < MAX; i++)
    {
        pthread_mutex_lock(&mut);
        number++;
        printf("子线程1：临界变量的值为%d\n", number);
        pthread_mutex_unlock(&mut);
        sleep(2);
    }
    pthread_exit(NULL);
}

void *thread2()
{
    for (i = 0; i < MAX; i++)
    {
        pthread_mutex_lock(&mut);
        number++;
        printf("子线程2：临界变量的值为%d\n", number);
        pthread_mutex_unlock(&mut);
        sleep(3);
    }
    pthread_exit(NULL);
}

void thread_create()
{
    int temp;
    memset(&thread, 0, sizeof(thread));
    if ((temp = pthread_create(&thread[0], NULL, thread1, NULL)) != 0)
        printf("子线程1创建失败!\n");
    else
        printf("子线程1创建成功\n");
    if ((temp = pthread_create(&thread[1], NULL, thread2, NULL)) != 0)
        printf("子线程2创建失败\n");
    else
        printf("子线程2创建成功\n");
}

void thread_wait()
{
    if (thread[0] != 0)
    {
        pthread_join(thread[0], NULL);
        printf("子线程1结束\n");
    }
    if (thread[1] != 0)
    {
        pthread_join(thread[1], NULL);
        printf("子线程2结束\n");
    }
}

void multi_thread()
{
    MAX = (rand() % (20 - 5 + 1)) + 5;
    pthread_mutex_init(&mut, NULL);
    printf("临界变量的初始值为%d\n", number);
    printf("创建子线程\n");
    thread_create();
    printf("等待子线程完成\n");
    thread_wait();
}
END_TEXT
else
    # Makefile
    cat >Makefile <<END_TEXT
cc = g++
prom = main
inc = include/
deps = \$(shell find ./ -name "*.hpp")
src = \$(shell find ./ -name "*.cpp")
obj = \$(src:%.cpp=%.o)
libs = -lpthread
\$(prom): \$(obj)
	\$(cc) -std=c++17 -o \$(prom) \$(obj) \$(libs)
%.o: %.cpp \$(deps)
	\$(cc) -std=c++17 -c \$< -o \$@ -I \$(inc)
run: \$(prom)
	./\$(prom)
clean:
	rm -rf \$(prom) \$(obj)
END_TEXT
    # main.hpp
    cat >include/main.hpp <<END_TEXT
//main.hpp
#include <iostream>
#include "sin_value.hpp"
#include "cos_value.hpp"
#include "tan_value.hpp"
#include "multi_thread.hpp"
END_TEXT
    # main.cpp
    cat >main.cpp <<END_TEXT
//main.cpp
#include "main.hpp"
double pi = 3.1415926535898;
int main()
{
    double angle;
    std::cout << "输入一个度数：";
    std::cin >> angle;
    sin_value(angle);
    cos_value(angle);
    tan_value(angle);
    multi_thread();
    return 0;
}
END_TEXT
    # sin_value.hpp
    cat >include/sin_value.hpp <<END_TEXT
//sin_value.hpp
void sin_value(double);
END_TEXT
    # sin_value.cpp
    cat >sin_value.cpp <<END_TEXT
//sin_value.cpp
#include <iostream>
#include <math.h>
extern double pi;
void sin_value(double angle)
{
    std::cout << "The sin " << angle << " is " << sin(angle / 180.0 * pi) << std::endl;
}
END_TEXT
    # cos_value.hpp
    cat >include/cos_value.hpp <<END_TEXT
//cos_value.hpp
void cos_value(double);
END_TEXT
    # cos_value.cpp
    cat >cos_value.cpp <<END_TEXT
//cos_value.cpp
#include <iostream>
#include <math.h>
extern double pi;
void cos_value(double angle)
{
    std::cout << "The cos " << angle << " is " << cos(angle / 180.0 * pi) << std::endl;
}
END_TEXT
    # tan_value.hpp
    cat >include/tan_value.hpp <<END_TEXT
//tan_value.hpp
void tan_value(double);
END_TEXT
    # tan_value.cpp
    cat >tan_value.cpp <<END_TEXT
//tan_value.cpp
#include <iostream>
#include <math.h>
extern double pi;
void tan_value(double angle)
{
    std::cout << "The tan " << angle << " is " << tan(angle / 180.0 * pi) << std::endl;
}
END_TEXT
    # multi_thread.hpp
    cat >include/multi_thread.hpp <<END_TEXT
//multi_thread.hpp
void multi_thread();
END_TEXT
    # multi_thread.cpp
    cat >multi_thread.cpp <<END_TEXT
//multi_thread.cpp
#include <iostream>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

pthread_t thread[2];
pthread_mutex_t mut;
int MAX;
int number = 0;
int i;

void *thread1(void *)
{
    for (i = 0; i < MAX; i++)
    {
        pthread_mutex_lock(&mut);
        number++;
        std::cout << "子线程1：临界变量的值为" << number << std::endl;
        pthread_mutex_unlock(&mut);
        sleep(2);
    }
    pthread_exit(NULL);
}

void *thread2(void *)
{
    for (i = 0; i < MAX; i++)
    {
        pthread_mutex_lock(&mut);
        number++;
        std::cout << "子线程2：临界变量的值为" << number << std::endl;
        pthread_mutex_unlock(&mut);
        sleep(3);
    }
    pthread_exit(NULL);
}

void thread_create()
{
    int temp;
    memset(&thread, 0, sizeof(thread));
    if ((temp = pthread_create(&thread[0], NULL, thread1, NULL)) != 0)
        std::cout << "子线程1创建失败!" << std::endl;
    else
        std::cout << "子线程1创建成功!" << std::endl;
    if ((temp = pthread_create(&thread[1], NULL, thread2, NULL)) != 0)
        std::cout << "子线程2创建失败!" << std::endl;
    else
        std::cout << "子线程2创建成功!" << std::endl;
}

void thread_wait()
{
    if (thread[0] != 0)
    {
        pthread_join(thread[0], NULL);
        std::cout << "子线程1结束!" << std::endl;
    }
    if (thread[1] != 0)
    {
        pthread_join(thread[1], NULL);
        std::cout << "子线程2结束!" << std::endl;
    }
}

void multi_thread()
{
    MAX = (rand() % (20 - 5 + 1)) + 5;
    pthread_mutex_init(&mut, NULL);
    std::cout << "临界变量的初始值为" << number << std::endl;
    std::cout << "创建子线程" << std::endl;
    thread_create();
    std::cout << "等待子线程完成" << std::endl;
    thread_wait();
}
END_TEXT
fi
sudo chown ${USER}: -R ${HOME}/$project_name/
echo "项目文件夹$project_name已经保存至主目录下"
