#samba安装
yum -y install smaba*
#创建用户
useradd apache
smbpasswd -a apache
#配置文件
vim /etc/samba/smb.conf
[web]
comment = 91 web
path = /var/www/
browseable = yes
writable = yes
#开机启动
chkconfig smb on
chkconfig --list smb
#测试
net use /delete *
#设置权限
ps -ef |grep httpd
 # setfacl设置apache用户对file文件的rwx权限,getfacl可查看权限
 # -m, --modify=acl        modify the current ACL(s) of file(s)
 # -d, --default           operations apply to the default ACL
 # -R, --recursive         recurse into subdirectories 
setfacl -m d:u:apache:rwx -R /var/www/
#统一权限(acl权限,apache进程执行者,samba访问用户)
vi /etc/httpd/conf/httpd.conf 
User apache
Group apache

