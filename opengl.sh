#!/bin/bash
dir_input=$0
dir_input="${dir_input%/*}"
cd $dir_input
error=1
if [ -n "$1" ] && [ ! -n "$2" ]; then
    if [ $1 = "1" ]; then
        error=0
        echo "安装OpenGL..."
        sudo apt-get install g++ binutils build-essential -y
        sudo apt-get install freeglut3-dev libgl1-mesa-dev libglu1-mesa-dev \
            libglew-dev libglm-dev mesa-utils mesa-common-dev -y
    elif [ $1 = "0" ]; then
        error=0
        echo "卸载OpenGL..."
        sudo apt-get --purge remove freeglut3-dev libgl1-mesa-dev libglu1-mesa-dev \
            libglew-dev libglm-dev mesa-utils mesa-common-dev -y
        rm -rf OpenGLtest.cpp main
    elif [ $1 = "h" ]; then
        error=0
        if [ -f OpenGLtest.cpp ]; then
            rm -rf OpenGLtest.cpp
        fi
        touch OpenGLtest.cpp
        cat >OpenGLtest.cpp <<END_TEXT
#include <stdio.h>
#include <GL/glew.h>
#include <GL/glut.h>

int x, y;
float r, g, b;

void idle()
{
    x = rand() % 640;
    y = rand() % 480;
    r = (float)((rand() % 9)) / 8;
    g = (float)((rand() % 9)) / 8;
    b = (float)((rand() % 9)) / 8;
    glutPostRedisplay();
}

void magic_dots(void)
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, 640.0, 0.0, 480.0);
    glColor3f(r, g, b);
    glBegin(GL_POINTS);
    glVertex2i(x, y);
    glEnd();
    glFlush();
}

// g++ OpenGLtest.cpp -o main -lglut -lGL -lGLU -lGLEW;./main
int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE);
    glutInitWindowSize(640, 480);
    glutCreateWindow("Randomly Generated Points");
    GLenum err = glewInit();
    if (GLEW_OK != err)
    {
        fprintf(stderr, "Error: %s\n", glewGetErrorString(err));
    }
    fprintf(stdout, "Status: Using GLEW %s\n", glewGetString(GLEW_VERSION));
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    glutDisplayFunc(magic_dots);
    glutIdleFunc(idle);
    glutMainLoop();
    return 0;
}
END_TEXT
        echo "已在shell下生成测试文件OpenGLtest.cpp"
        echo "g++ OpenGLtest.cpp -o main -lglut -lGL -lGLU -lGLEW;./main"
    fi
fi
if [ $error = "1" ]; then
    echo "./opengl.sh 1		安装OpenGL"
    echo "./opengl.sh 0		卸载OpenGL"
    echo "./opengl.sh h		关于OpenGL"
fi
