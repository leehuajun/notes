
# MacOS 下面配置 JDK 环境

## 下载 JDK Oracle 官网
    访问Oracle官网 http://www.oracle.com

## JDK 默认安装路径
    /Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home

## JDK 目录说明
    bin目录下存放JDK用于开发的一些终端命令工具。常见的工具如：
    “javac”的作用是将java源文件编译为class文件(即自解码文件)；
    “java”命令的作用是运行class文件。
    db目录下是java开发的一个开源的关系型数据库；
    include目录下是一些C语言的头文件；
    jre目录下JDK所依赖的java运行时；
    lib目录下存放JDK开发工具所依赖的一些库文件；
    man目录下存放JDK开发工具的说明文档。
    
## 测试 JDK
    然后输入”java -version”，如果看到jdk版本为1.8则说明配置已经生效：

## 配置环境变量
```shell
JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_40.jdk/Contents/Home
PATH=$JAVA_HOME/bin:$PATH:.
CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.
export JAVA_HOME
export PATH
export CLASSPATH
```