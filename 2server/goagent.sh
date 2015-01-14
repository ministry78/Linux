yum groupinstall "Development Tools"
yum install -y python python-devel libevent libevent-devel
wget http://pypi.douban.com/simple/greenlet/greenlet-0.4.0.zip
wget https://gevent.googlecode.com/files/gevent-1.0b4.tar.gz

安装gevent和greenlet

unzip greenlet-0.4.0.zip
cd greenlet-0.4.0
./setup.py install
cd ..
tar xzvf gevent-1.0b4.tar.gz
cd gevent-1.0b4
./setup.py install
当然你这些东西都准备好了，可以跳过这一步。接下来我们来配置goagent

cd goagent/server
python uploader.zip
这个时候会提示你填写appid。如下图

然后跟着提示往下面走就行了，如果你没有google的appid可以去申请一个也不麻烦

设置好之后，接下来我们需要给wget弄一个代理配置
vim ~/.wgetrc
http_proxy = http://127.0.0.1:8087
https_proxy = http://127.0.0.1:8087
ftp_proxy = http://127.0.0.1:8087
 
#设置是否自动使用代理
use_proxy = off
然后我们就可以使用wget翻墙下载软件了。
由于我们设置了不自动使用代理，我们在使用wget命令的使用需要加上 -Y on来开启代理，当然在需要翻墙的时候我们需要开启goagent

?
1
2
cd goagent/local/
python proxy.py
基本上用wget+goagent的配置就是这样子。

参考：https://code.google.com/p/goagent/wiki/GoAgent_Linux
http://www.cnblogs.com/cloud2rain/archive/2013/03/22/2976337.html

Reported by siwind.w...@gmail.com, May 17, 2013
0) download packages needed!
   gevent: https://code.google.com/p/gevent/downloads/list , here download "gevent-1.0b4.tar.gz"
   greenlet: http://pypi.python.org/pypi/greenlet  , download package "greenlet-0.4.0.zip"

1) using yum to install essencial package!
   #sudo yum groupinstall "Development Tools"
   #sudo yum install python python-devel libevent libevent-devel

2) install greenlet and gevent
   #unzip greenlet-0.4.0.zip
   #cd greenlet-0.4.0
   #sudo ./setup.py install
   #cd
   #tar xzvf gevent-1.0b4.tar.gz
   #cd gevent-1.0b4
   #sudo ./setup.py install
3) That's all! Let's run goagent now:
   #python goagent/local/proxy.py