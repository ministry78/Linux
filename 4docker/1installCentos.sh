#!/bin/bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
yum makecache
#install and start
yum -y install docker-io
service docker start
#make Centos image
yum -y install febootstrap
febootstrap -i bash -i wget -i yum -i iputils -i iproute -i man -i vim-minimal -i openssh-server -i openssh-clients centos6 centos6-image http://mirrors.aliyun.com/centos/6/os/x86_64/
	#make image and named centos6-base mode
cd centos6-image && tar -c .|docker import - centos6-base
#make ssh image for Centos60base
docker build -t centos6-ssh https://git.oschina.net/feedao/Docker_shell/raw/start/Dockerfile


#########################################################
#user:root   password:123456
#make container
# docker run -d -p 127.0.0.1:33301:22 centos6-ssh
#login ssh
# ssh root@127.0.0.1 -p 33301
###########################################################
