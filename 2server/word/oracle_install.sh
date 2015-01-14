#oracle
rpm -ivh http://mirrors.aliyun.com/epel/6Server/x86_64/epel-release-6-8.noarch.rpm
#必要组件
yum install -y vim ntp gcc gcc-c++ man make unzip openssl openssl-devel screen tree wget curl curl-devel autoconf automake binutils-devel bison cpp dos2unix ftp  lrzsz python-devel
# 安装kernel-devel和kernel-headers，并且在更新系统时，禁止更新kernel
yum -y install kernel-devel kernel-headers && echo exclude=kernel* >> /etc/yum.conf
# 安装oracle 必要组件：
yum -y install compat-db compat-gcc-34 compat-gcc-34-c++ compat-libstdc++-33 glibc-* glibc-*.i686 libXpm-*.i686 libXp.so.6 libXt.so.6 libXtst.so.6 libgcc_s.so.1 ksh libXp libaio-devel numactl numactl-devel unixODBC unixODBC-devel elfutils-libelf-devel libgcc libstdc++ sysstat

yum update -y
reboot


#调整内核参数
vi /etc/sysctl.conf
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 536870912
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
fs.aio-max-nr = 1048576
#让内核参数生效
sysctl -p

#修改limits.conf
vi /etc/security/limits.conf
#oracle settings
oracle           soft    nproc   2047
oracle           hard    nproc   16384
oracle           soft    nofile  1024
oracle           hard    nofile  65536

#修改系统版本（Redhat 5.×系列系统略过这步）
cp /etc/redhat-release /etc/redhat-release.bk
vi /etc/redhat-release
#修改内容为：
Red Hat Enterprise Linux AS release 6

#修改
vi /etc/pam.d/login
#添加以下内容：
session    required     /lib/security/pam_limits.so
session    required     pam_limits.so

#修改/etc/profile
vi /etc/profile
#添加以下内容：
if [ $USER = "oracle" ]; then
   if [ $SHELL = "/bin/ksh" ]; then
      ulimit -p 16384
      ulimit -n 65536
   else
      ulimit -u 16384 -n 65536
   fi
fi

#修改/etc/csh.login
vi /etc/csh.login
#添加以下内容:
if ( $USER == "oracle" ) then
     limit maxproc 16384
     limit deors 65536
endif

四、创建oracle用户
groupadd oinstall
groupadd dba
useradd -g oinstall -G dba oracle
passwd oracle     89641551

mkdir -p /data/oracle
mkdir -p /data/oralnventory
mkdir -p /data/software
chown -R oracle:oinstall /data/oracle
chown -R oracle:oinstall /data/software
chown -R oracle:oinstall /data/oralnventory

#设置用户环境变量
#
su - oracle
$

cd ~
vi .bash_profile 
#添加以下内容：

#oracle setting
ORACLE_SID=ilas; export ORACLE_SID
ORACLE_BASE=/data/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1; export ORACLE_HOME
PATH=$PATH:$ORACLE_HOME/bin:$HOME/bin; export PATH

$
source .bash_profile

五、安装oracle
#上传oracle安装文件到/data/software目录下，并解压
cd /data/software
unzip linux_11gR2_database_1of2.zip
unzip linux_11gR2_database_2of2.zip
xhost +   #(这里使用root用户执行,一定要执行以下2步，如果没有执行，将无法启动图形安装界面)
xhost + ilasDB
su - oralce
cd /data/software/database
$./runInstaller  #(到oracle安装文件所在目录执行该命令)

#以root身份执行脚本
su    切换回root用户
/data/oralnventory/orainstRoot.sh
/data/oracle/product/11.2.0/db_1/root.sh
安装之后再点上图的确定

六、开机启动设置
#自动启动和关闭数据库实例和监听
vi /data/oracle/product/11.2.0/db_1/bin/dbstart

ORACLE_HOME_LISTNER=$1
#修改为：
ORACLE_HOME_LISTNER=$ORACLE_HOME

vi /etc/init.d/oracle
#!/bin/sh
# chkconfig: 345 61 61
# description: Oracle 11g AutoRun Services
# /etc/init.d/oracle
#
# Run-level Startup script for the Oracle Instance, Listener, and
# Web Interface

export ORACLE_BASE=/data/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export ORACLE_SID=ilas
export PATH=$PATH:$ORACLE_HOME/bin
ORA_OWNR="oracle"

# if the executables do not exist -- display error


if [ ! -f $ORACLE_HOME/bin/dbstart -o ! -d $ORACLE_HOME ]
then
     echo "Oracle startup: cannot start"
     exit 1
fi

# depending on parameter -- startup, shutdown, restart
# of the instance and listener or usage display

case "$1" in
 start)
     # Oracle listener and instance startup
     su $ORA_OWNR -lc $ORACLE_HOME/bin/dbstart
     echo "Oracle Start Succesful!OK."
     ;;
 stop)
     # Oracle listener and instance shutdown
     su $ORA_OWNR -lc $ORACLE_HOME/bin/dbshut
     echo "Oracle Stop Succesful!OK."
     ;;
 reload|restart)
     $0 stop
     $0 start
     ;;
 *)
     echo $"Usage: `basename $0` {start|stop|reload|reload}"
     exit 1
esac
exit 0

chmod 750 /etc/init.d/oracle
ln -s /etc/init.d/oracle /etc/rc1.d/K61oracle
ln -s /etc/init.d/oracle /etc/rc3.d/S61oracle
chkconfig --level 345 oracle on
chkconfig --add oracle

#启动oracle
service oracle start



#自动启动和关闭 EM
vi /etc/init.d/oraemctl
#!/bin/sh
# chkconfig: 345 61 61
# description: Oracle 11g AutoRun Services
# /etc/init.d/oraemctl
#
# Run-level Startup script for the Oracle Instance, Listener, and
# Web Interface

export ORACLE_BASE=/data/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export ORACLE_SID=ilas
export PATH=$PATH:$ORACLE_HOME/bin
ORA_OWNR="oracle"

case "$1" in
start)
echo -n $"Starting Oracle EM DB Console:"
su - $ORACLE_OWNER -c "$ORACLE_HOME/bin/emctl start dbconsole"
echo "OK"
;;
stop)
echo -n $"Stopping Oracle EM DB Console:"
su - $ORACLE_OWNER -c "$ORACLE_HOME/bin/emctl stop dbconsole"
echo "OK"
;;
*)
echo $"Usage: $0 {start|stop}"
esac

chmod 750 /etc/init.d/oraemctl
#启动EM
service oraemctl start

 

ILAS III 的安装说明
一、在centos创建ilas用户和数据库
1，首先在/data创建文件夹,取名:oradata.
#root $oracle
[oracle@ilasdb001 data]
su root
mkdir -p /data/oradata
chown -R oracle:oinstall /data/oradata
#ls
#su oracle
$
sqlplus /nolog
SQL> conn sys/sys as sysdba; 回车.这样就连接上了.
SQL> shutdown immediate; 回车， ORACLE 例程已经关闭 lsnrctl start
SQL> startup; 回车 ORACLE例程已经启动 （如下图）
2,创建ilas表空间
Linux
Create tablespace ilas datafile '/data/oradata/ilas.dbf' size 3000M reuse autoextend on next 10M;
windows
Create tablespace ilas datafile 'E:\oradata\ilas.dbf' size 3000M reuse autoextend on next 10M;
// 创建ilas表空间，datefile是表空间的物理地址，3000000k的表的预设大小。超过，表空间将10M自动增加。
3,SQL:Create user ilas identified by ilas default tablespace ilas;
//在表空间ilas里面，创建ilas用户，密码是ilas。
SQL:Grant dba to ilas; //授权给ilas。
4,导入ILAS备份
把备份更名为ilas.DMP。放到d:\ilasdmp下。
然后 开始-运行-sqlplus /nolog 回车
SQL：Conn sys/sys as sysdba;
//用管理员的身份登陆,”/”前面是用户名 ,后面是密码。
SQL：Shutdown immediate； //快速关闭服务器。
SQL：Startup； //启动服务器。
SQL：drop user ilas cascade； //删除用户。
SQL：Create user ilas identified by ilas default tablespace ilas；
//在表空间ilas里面，创建ilas用户，密码是ilas。
SQL：Grant dba to ilas； //授权给ilas。
用户已建立，授权成功
5，双击E:\ilasdmp中的“导入.dat
然后出现以下格式：
显示导入成功
（注意：如需导出ilas备份，直接双击d:\ilasdmp中的“导出.dat）
imp ilas/ilas file=./ilas.dmp fromuser=ilas touser=ilas
windows
 imp ilas/ilas  file=F:\#ilas_backup\ilasBak121210AM.dmp fromuser=ilas touser=ilas grants=n indexes=y rows=y constraints=y
