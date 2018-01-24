# Docker 学习笔记

# 1. 镜像
## 1) 获取镜像
默认获取latest版本
```shell
docker pull ubuntu
```
指定获取latest版本
```shell
docker pull ubuntu:latest
```
指定获取16.10版本
```shell
docker pull ubuntu:16.10
```
## 2) 使用镜像，就是利用镜像创建一个容器，提供某些服务
利用镜像创建一个容器，在其中运行bash应用
```shell
docker run -t -i ubuntu /bin/bash  
```   
## 3)查看镜像信息
列出本地机器上已有的镜像
```shell
docker images
```
为mysql:5.7生成一个新的标签：sunjet/mysql:5.7，两个标签都指向同一个镜像 
```shell
docker tag mysql:5.7 sunjet/mysql:5.7
```
查看mysql:5.7镜像的json格式的信息
```shell  
docker inspect mysql:5.7
```
搜索远端仓库中共享的镜像  
```shell
docker search mysql 
```
搜索星级为20以上（包括20）的mysql镜像
```shell  
docker search mysql —filter=stars=20
```
## 4) 删除镜像
删除镜像，也可以通过image_id来删除镜像，如果同一个镜像有多个标签，改命令只是删除一个tag，不会真的删除镜像，如果是镜像的最后一个tag，则会删除该tag对应的镜像。此外，如果有该镜像创建的容器存在时，镜像文件默认是服务删除的。
```shell
docker rmi sunjet/mysql:5.7
```
如果有该镜像创建的容器存在时，使用参数-f，可以强制删除该镜像，不建议这么做。应该先删除对应的容器，再来删除镜像
```shell
docker rmi -f mysql:5.7
```
根据镜像的id删除镜像
```shell
docker rmi -f image_id
```
## 5) 存出和载入镜像
把镜像mysql:5.7存出成本地的mysql_5.7.tar镜像文件
```shell
docker save -o mysql_5.7.tar mysql:5.7
```
载入本地镜像文件
```shell
docker load < mysql_5.7.tar
```
载入本地镜像文件
```shell
docker load —input mysql_5.7.tar
```
## 上传镜像
用户user上传本地的test:latest镜像，可以先添加新的标签：
> 添加新的标签
```shell
docker tag test:latest user/test:latest
```
> 上传镜像（会提示输入用户密码）
```shell
docker push user/test:latest
```
# 2. 容器
## 1) 创建容器
使用该命令新建的容器处于停止状态，可以使用docker start命令来启动它。
```shell
docker create -it ubuntu:latest
```
通过容器id，启动容器
```shell
docker start container_id
```
## 2) 创建并启动容器
该命令输出一个"hello world"，之后容器自动终止
```shell
docker run ubuntu /bin/echo 'hello world'
```
该命令启动一个bash终端，允许用户进行交互，-t选项让Docker分配一个伪终端，并绑定到容器的标准输入上，-i则让容器的标准输入保持打开，当在bash容器中输入exit命令退出之后，该容器就自动处于终止状态
```shell
docker run -t -i ubuntu:14.04 /bin/bash
```
## 3) 守护态运行
使用-d参数，让容器在后台运行
```shell
docker run -d ubuntu /bin/sh -C "while true;do echo hello world;sleep 1;done"
```
查询所有容器
```shell
docker ps
```
查询所有正在运行的容器
```shell
docker ps -a
```
查询处于终止状态的容器的ID信息
```shell
docker ps -a -q
```
根据容器的id，获取容器的输出信息
```shell
docker logs container_id
```
## 4) 终止容器
根据容器id，停止容器，首先向容器发送SIGTERM信号，等待一段时间（默认10秒）再发送SIGKILL信号终止容器
```shell
docker stop container_id
```
根据容器id，直接发送SIGKILL信号来强行终止容器
```shell
docker kill container_id
```
启动处于终止状态的容器
```shell
docker start container_id
```
重启一个处于运行态的容器，先终止，再启动
```shell
docker restart container_id
```
## 5) 进入容器
打开bash窗口，在里面可以运行shell指令
```shell
docker attach  container_id
```
进入运行态的容器，并启动一个bash，可以执行shell指令
```shell
docker exec -it container_id /bin/bash
```
## 6) 删除容器
删除处于终止状态的容器
```shell
docker rm container_id
```
强行终止并删除一个运行中的容器
```shell
docker rm -f container_id
```
删除容器挂在的数据卷
```shell
docker rm -v container_id
```
## 7) 导入和导出容器 
根据容器id，导出到本地的一个tar文件
```shell        
docker export container_id > test_for_run.tar
```
导入tar文件生成新镜像，该命令是导入一个容器快照到本地镜像库，和docker load的区别是：容器快照文件将丢弃所有的历史记录和元数据信息（即仅保存容器当时的快照状态），而镜像存储文件将保存完整记录，体积也要大。
```shell
cat test_for_run.tar | (sudo) docker import - test/ubuntu:v1.0
```
# 3. 仓库 
## 1) 使用registry镜像创建私有仓库
使用默认方式下载并启动一个registry容器，创建本地的私有仓库服务
```shell
docker run -d -p 5000:5000 registry
```
启动服务，使用-v参数来将镜像文件存放在本地的指定路径上 
```shell
docker run -d -p 5000:5000 -v /opt/data/registry:/tmp/registry registry
```
## 2) 管理私有仓库镜像 
格式要求：docker tag IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]         
```shell
docker tag ubuntu:14.04 192.168.56.101:5000/test
```
上传镜像
```shell
docker push 192.168.56.101:5000/test
```
用curl查看仓库 192.168.56.101:5000 中的镜像
```shell
curl http://192.168.56.101:5000/v1/search
```
# 4. 数据管理
## 1) 数据卷
创建一个容器，把本地的/src/webapp目录挂在到容器的/opt/webapp目录中，ro表示只读，默认为读写（rw）挂在一个本地主机文件作为数据卷
```shell
docker run -d -P —name web -v /src/webapp:/opt/webapp:ro centos:latest     
```
这样就可以记录在容器输入过的历史命令了（不建议）
```shell
docker run —rm -it -v ~/.bash_history:/.bash_history centos /bin/bash
```
## 2) 数据卷容器
基于centos镜像创建一个名字为dbdata的容器，容器的/dbdata目录指向本地目录/Users/lhj/dbdata
```shell
docker run -it -v /Users/lhj/dbdata:/dbdata --name dbdata centos     
```
基于centos镜像创建一个db1容器，同时从dbdata数据卷容器挂在数据卷   注意：使用 —volumes-from参数所挂载数据卷的容器自身并不需要保持在运行状态
```shell
docker run -it --volumes-from dbdata --name db1 centos             
```
## 3) 备份
创建一个容器worker，使用—volumes-from dbdata参数让worker挂载dbdata的数据卷，使用 -v ${pwd}:/backup参数来挂载本地的当前目录到worker的/backup目录
```shell
docker run -it —volumes-from dbdata -v $(pwd):/backup —name worker centos
```
在上面创建的容器bash上执行，把目录dbdata备份到宿主机器挂载那个/backup的目录上面。
```shell
tar cvf /backup/backup.tar /dbdata
```
把上面两条语句一次执行：创建启动容器，并执行备份操作，然后终止容器，就在当前目录中创建了一个backup.tar文件。
```shell
docker run —volumes-from dbdata -v $(pwd):/backup —name worker centos tar cvf /backup/backup.tar /dbdata
```
## 4) 恢复
把backup.tar，恢复到新创建的容器的/dbdata目录下面
```shell
docker run --volumes-from dbdata -v $(pwd):/backup centos tar xvf /backup/backup.tar
```
# 5. 网络基础配置
## 1) 端口映射
使用-P，docker会随机映射一个端口至容器内部开放的网络端口
```shell
docker run -d -P training/webapp
```
查看容器的日志，-f表示不退出，实时查看
```shell
docker logs  (-f) container_name或container_id
```
使用-p（小写）,将本地的5000端口映射到容器的5000端口。本地的所有网卡接口都会映射
```shell
docker run -d -p 5000:5000 training/webapp
```
多次使用-p标记可以绑定多个端口。本地的所有网卡接口都会映射
```shell
docker run -d -p 5000:5000 -p 3000:80 training/webapp
```
绑定一个特定地址
```shell
docker run -d -p 127.0.0.1:5000:5000 training/webapp
```
帮定特定地址的任意端口
```shell
docker run -d -p 127.0.0.1::5000 training/webapp
```
使用udp标记来指定udp端口
```shell
docker run -d -p 127.0.0.1:5000:5000/udp training/webapp
```
查看容器5000端口映射到本地的哪个端口上。
```shell
docker port container_id或container_name 5000
```
## 2) 容器互联实现容器间通信
创建一个新的数据库容器，启动时，没有使用-p和-P标记，避免暴露数据库单口到外部网络上。
```shell
docker run -d --name db training/postgres
```
创建一个web容器，使用—link db:db，连接到db容器   格式：—link name:alias ,其中，name是要连接的容器的名称，alias是这个连接的别名
```shell
docker run -d -P --name web --link db:db training/webapp python app.py
```
docker通过两种方式为容器公开连接信息：
> 环境变量
> 更新 /etc/hosts 文件
>> 使用env命令查看web容器的环境变量
```shell
docker run --rm --name web --link db:db training/webapp env
```
>> 启动并进入bash，使用cat /etc/hosts 命令查看信息，用户可以连接多个子容器到父容器，比如可以连接多个web到db容器上。
```shell
docker run -it --rm --link db:db training/webapp /bin/bash
```
# 6. 使用Dockerfile创建镜像     
## 1) Dockerfile文件简单介绍
注释行以#开头，Dockerfile分为四部分：基础镜像信息、维护者信息、镜像操作指令、容器启动时执行指令。如：
```shell	
# This dockerfile uses the ubuntu image
# VERSION 2 - EDITION 1
# Author : docker_user
# Command format Instruction [arguments / command]..
# 第一行必须指定基于的基础镜像
FROM ubuntu
# 维护者信息
MAINTAINER docker_user docker_user@email.com
# 镜像的操作指令
RUN echo "deb http://archive.ubuntu.com/ubuntu/ raring main universe" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
# 容器启动时执行指令
CMD /usr/sbin/nginx
```

## 2) 指令介绍
标签|格式
-|-
FROM|格式：FROM <image>或 FROM <image>:<tag>
MAINTAINER|格式：MAINTAINER <name>,指定维护者信息。
RUN|格式：RUN <command> 或 RUN ["executable","param1","param2"]，前者将在shell终端中运行命令，即/bin/sh -c；后者则使用exec指令。
RUN ["/bin/bash","-C", "echo hello"].|注意：每条RUN指令将在当前镜像基础上执行指定命令，并提交为新的镜像。当命令较长时可以使用 \ 来换行。
CMD|格式： CMD ["executable","param1","param2"]   使用exec执行，推荐方式
CMD command param1 param2|在/bin/sh中执行，提供给需要交互的应用
CMD ["param1","param2"]|提供给ENTRYPOINT的默认参数,注意：指定启动容器时执行的命令，每个Dockerfile只能有一条CMD命令，如果指定了多条，只有最后一条会被执行。如果用户启动容器时指定了运行的命令，则会覆盖CMD指定的命令
EXPOST|格式：EXPOSE  <port> [<port>…]  比如：EXPOSR 22 80 8443      告诉Docker服务端容器暴露的端口号
ENV|格式：ENV  <key> <value> 指定环境变量，会被后续RUN指令使用，并在容器运行时保持。例如： ENV PG_MAJOR 9.3
ENV|PG_VERSION 9.3.4
RUN curl -SL http://example.com/postgres-$PG_VERSION.tar.xz | tar - xJC /usr/src/postgress && …
ENV PATH /usr/local/postgres-$PG_MAJOR/bin:$PATH|
ADD|格式： ADD <src> <dest> 将复制指定的<src>到容器中的<dest>。其中<src>可以是Dockerfile所在目录的一个相对路径(文件或目录)；也可以是一个URL，还可以是一个tar文件（自动解压为目录）
COPY|格式：COPY <src> <dest>   复制本地主机的<src>（为Dockerfile所在目录的相对路径，文件或目录）为容器中的<dest>。目标路径不存在时，会自动创建。当使用本地目录为源目录时，推荐使用COPY
ENTRYPOINT|格式：ENTRYPOINT    ["executable","param1","param2"]
ENTRYPOINT    command param1 param2 (shell中执行)|配置容器启动后执行的命令，并且不可被docker run提供的参数覆盖,每个Dockerfile中只能有一个ENTRYPOINT，当指定了的多个时，只有最后一个生效。
VOLUME|格式：VOLUME ["/data"]    创建一个可以从本地主机或其他容器挂在的挂载点，一般用来存放数据库和和需要保持的数据等。
USER|格式：USER daemon     指定运行容器时的用户名或UID，后续的RUN也会使用指定用户
RUN groupadd -r postgres && useradd -r -g postgres postgres|当服务不需要管理员权限时，可以通过该命令指定运行用户。冰鞋可以在之前创建所需要的用户，要零时获取管理员权限可以使用gosu，不推荐使用sudo。
WORKDIR|格式：WORKDIR /path/to/workdir    为后续的RUN、CMD、ENTRYPOINT指定配置工作目录。可以使用多个WORKDIR指令，后续命令如果参数是相对路径，则会基于之前命令指定的路径。例如：WORKDIR /a     路径为/a - WORKDIR b 路径为/a/b -WORKDIR c 路径为/a/b/c  RUN pwd  则最终的路径为/a/b/c
ONBUILD|格式：ONBUILD [INSTRUCTION]   配置当所创建的景象作为其他新创建镜像的基础镜像时，所执行的操作指令

## 3) 创建镜像
Dockerfile路径在/tmp/docker_builder/下面，如果为当前目录，则使用 . 表示，创建的镜像为:build_repo/first_image   -t 表示指定镜像的标签信息
```shell
docker build -t build_repo/first_image /tmp/docker_builder/            
```


## 7. 使用技巧

## docker 批量删除命令

不知道大家情况如何，自己的电脑总是没多久就一堆各种镜像，对于些许有点强迫症的我免不了需要经常的清理这些docker镜像。

杀死所有正在运行的容器
```shell
docker kill $(docker ps -a -q)
```
删除所有已经停止的容器
```shell
docker rm $(docker ps -a -q)
```

删除所有未打 dangling 标签的镜像
```shell
docker rmi $(docker images -q -f dangling=true)
```

删除所有镜像   强制删除镜像名称中包含"doss-api"的镜像
```shell
docker rmi --force $(docker images | grep doss-api | awk '{print $3}')
```
## Java 示例代码(测试语法高亮)
```java
public class App{
	public static void main(String[] args){
		System.out.pringln("Hello World!");
	}
}
```



