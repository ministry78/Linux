#!/bin/sh
[ ! -d /root/.ssh ] && mkdir -p /root/.ssh
ssh-keygen -q -N "" -t dsa -f /root/.ssh/id_dsa
KEY_PUB=`cat /root/.ssh/id_dsa.pub`
[ ! -d /root/docker-temp ] && mkdir /root/docker-temp
cd /root/docker-temp
cat >/root/docker-temp/Dockerfile <<EOF
#Dockerfile
FROM centos6-ssh
MAINTAINER feedao <feedao@163.com>
EOF
echo "RUN echo \"$KEY_PUB\" > /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys " >>Dockerfile
cd /root && cat /root/docker-temp/Dockerfile | docker build -t centos-newssh -

