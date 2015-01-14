#进入容器的方法
docker exec -i -t 容器ID /bin/bash

docker pull docker.cn/docker/mysql  #https://docker.cn/docker/mysql
docker pull docker.cn/docker/nginx  #https://docker.cn/docker/nginx
docker pull docker.cn/docker/redis  #https://docker.cn/docker/redis
docker pull docker.cn/docker/node  #https://docker.cn/docker/node
#如要看查看每个镜像的详细情况,可直接到相应网址查看dockerfile
docker images #查看镜像是否下载好

#启动redis
docker run -t -d -p 6379:6379  --name redis1 docker.cn/docker/redis:latest

#启动mysql
#MYSQL_ROOT_PASSWORD=password中为password mysql密码,可自己改
docker run -t -d  -p 3306:3306 -v /home/wsylib/wsyhelper:/wsyhelper --name mysql1 -e MYSQL_ROOT_PASSWORD=password docker.cn/docker/mysql:latest
#如要进入容器进行数据库操作
docker ps	#查看容器ID号
docker exec -i -t 45c79589d8ba /bin/bash #进入容器中更改,45c79589d8ba为容器ID
#将改好的容器可直接保存为一个新的镜像
docker commit -m="mysql1"  45c79589d8ba wsylib/mysql1:v1
#查看新的镜像可用性,新生成一个新容器查看
docker stop 45c79589d8ba #先关掉之前容器以免端口冲突
docker run -t -d -p 3306:3306 --name mysql2  wsylib/mysql1:v1
#如要打开之前的镜像
docker start 45c79589d8ba

#启动nodejs
docker run -t --rm --name nodejs2 -p 8888:8888 -v /home/wsylib/wsyhelper:/wsyhelper wsylib/nodejs1:v1 
#进入容器
docker ps
docker exec -i -t 7298fe7c15fb /bin/bash
#修改后保存为镜像
docker commit -m="nodejs1"  7298fe7c15fb wsylib/nodejs1:v1

