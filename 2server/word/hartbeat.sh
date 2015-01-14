wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-5.repo
# yum update -y

iptables -F;iptables -X;iptables -Z;service iptables save
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
reboot

yum -y install ntp
ntpdate time.nist.gov
date
echo '1 * * * * /usr/sbin/ntpdate time.nist.gov >/dev/null 2>&1' >>/var/spool/cron/root
scp /var/spool/cron/root node2:/var/spool/cron

vim /etc/hosts
localhost6
sed -i '/localhost6/a 10.0.5.13  node1.test.com  node1\
10.0.5.14  node2.test.com  node2 ' /etc/hosts

#node1
ssh-keygen  -t rsa -f ~/.ssh/id_rsa  -P ''
ssh-copy-id -i .ssh/id_rsa.pub root@node2.test.com
ssh node2
ifconfig 

#node2
ssh-keygen  -t rsa -f ~/.ssh/id_rsa  -P ''
ssh-copy-id -i .ssh/id_rsa.pub root@node1.test.com
ssh node1
ifconfig

#node1,2
yum -y install heartbeat* httpd
service httpd start

#node1
echo "<h1>IP10.0.5.13node1.test.com</h1>" > /var/www/html/index.html
curl http://node1
service httpd stop
chkconfig httpd off
chkconfig httpd --list
#node2
echo "<h1>IP10.0.5.14node2.test.com</h1>" > /var/www/html/index.html
curl http://node2
service httpd stop
chkconfig httpd off
chkconfig httpd --list

##配置heartbeat
cd /usr/share/doc/heartbeat-2.1.4/
cp authkeys ha.cf haresources /etc/ha.d/
cd /etc/ha.d/
dd if=/dev/random bs=512 count=1 | openssl md5
f03d706e064847fb45135b5a91d6e236
vim authkeys
	auth 1
	1 md5 f03d706e064847fb45135b5a91d6e236
chmod 600 authkeys
ll
vim ha.cf #修改
	bcast eth0
	#mcast eth0 225.100.100.100 694 1 0
	node node1.test.com
	node node2.test.com
vim haresources #增加IP地址为VIP
	node1.test.com IPaddr::10.0.5.10/16/eth0 httpd

scp authkeys ha.cf haresources node2:/etc/ha.d/
ssh node2
ll /etc/ha.d/

ssh node2 "service heartbeat start"
service heartbeat start
netstat -ntulp
curl -L http://10.0.5.10
#故障演示(关闭node1,查看node2能否直接接管)


#配置NFS10.0.13.62
yum install nfs-utils portmap -y (Centos5)
yum install nfs-utils rpcbind -y (Centos6)
mkdir -pv /web
vim /etc/exports
	/web/      10.0.0.0/24(ro,async)
	# rw：read-write，可读写；
	# ro：read-only，只读；
	# sync：同步写入（文件同时写入硬盘和内存），适用在通信比较频繁且实时性比较高的场合
	# async：异步写入（文件先写入内存，稍候再写入硬盘），性能较好（速度快），适合超大或者超多文件的写入，但有数据丢失的风险，比如突然断电等情况；
echo '<h1>Cluster NFS Server</h1>' > /web/index.html
/etc/init.d/rpcbind start && chkconfig --level 2345 rpcbind on
/etc/init.d/nfs start  && chkconfig --level 2345 nfs on
showmount -e 10.0.13.62

#node1
mount -t nfs 10.0.13.62:/web /mnt
cd /mnt
cat index.html
mount

#node2
mount -t nfs 10.0.13.62:/web /mnt
cd /mnt
cat index.html
mount

#node1
vim /etc/ha.d/haresources
	node1.test.com IPaddr::192.168.18.200/24/eth0 Filesystem::172.16.251.87:/web::/var/www/html::nfs httpd
scp /etc/ha.d/haresources node2:/etc/ha.d/

#重启heartbeat
ssh node2 "service heartbeat restart"
service heartbeat restart
netstat -ntulp
curl -L http://10.0.5.10

#测试故障
