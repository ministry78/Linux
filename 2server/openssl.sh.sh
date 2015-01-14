x509:
	公钥及其有效期限
	证书的合法拥有者
	证书该如何被使用
	CA的信息
	CA签名的校验码
PKI： TLS/SSL:x509
PKI: 

https:443
SSL:secure socket Layer	SSLv2,SSLv3
TLS:Transport Layer Security

https(tcp)
SSLv2,SSLv3,TLSv1
对称加密
	DES： Data Encrption Standard, 56bit
	3DES:
	AES:Advanced
		AES192,AES256,AES512
	Blowfish

单向加密
	MD4
	MD5
	SHA1
	SHA192，SHA256,SHA384
	CRC-32
非对称加密
公钥加密
	身份认证（数字签名）
	数据加密
	密钥交换
	
	RSA：加密、签名
	DSA：签名
	ElGamal
	
OpenSSL:SSL的开源实现
	libcrypto:加密库
	libssl:TLS/SSL的实现
		基于会话的、实现了身份认证、数据机密性和会话完整性的TLS/SSL库
	openssl:多用途命令行工具
		实现私有证书分发机构
		
		子命令：
			openssl speed des
			openssl command [ command_opts ] [ command_args ]

       openssl [ list-standard-commands | list-message-digest-commands | list-cipher-commands
       | list-cipher-algorithms | list-message-digest-algorithms | list-public-key-algorithms]
	   openssl enc -des3 -salt -a -in inittab -out inittab.des3
	   openssl enc -des3 -salt -a -in inittab.des3 -out inittab
	   提取特征码
		md5sum inittab
		sha1sum inittab
		openssl dgst -sha1 inittab
		

openssl实现私有CA：
1.创建CA
	生成一对密钥
	生成自签署证书
2.客户端
	生成一对密钥
	生成证书颁发请求，.csr
	将请求发给CA；
3.CA端
	签署此证书
	传送给客户端
	openssl genrsa -out /PATH/TO/KEYFILENAME NUMBITS
	opensll rsa -in /PATH/TO/KEYFILENAME -pubout
	(umask 077; openssl genrsa -out server1024.key 1024)
	openssl rsa -in server1024.key -pubout #通过私钥生成公钥
	
	openssl req -new -x509 -key server1024.key -out server.crt -days 365
	openssl x509 -text -in server.crt
	
	/etc/pki/tls/openssl.cnf
	(umask 077; openssl genrsa -out private/cakey.pem 1024)
	openssl req -new -x509 -key private/cakey.pem -out cacert.pem#自签证
	
	(umask 077; openssl genrsa -out httpd.key 1024)
	openssl req -new -key httpd.key -out httpd.csr#其它机器请求
	openssl ca in httpd.csr -out httpd.crt -days 365 #服务器身份证

OpenSSL：TLS/SSL,(libcryto,libssl,openssl),TLS PKI
OpenSSH:
	telnet,TCP/23,远程登录
		认证明文
		数据传输明文
	ssh:Secure Shell,TCP/22
C/S
ssh v1, v2
客户端：
	Linux：ssh
	Windows: putty,SecureCRT(),SSHSecureShellCient,Xmanager
服务器端：
	sshd
	
openssh(ssh,sshd)
ssh --> telnet
基于口令
基于密钥
netstat -l -n -t -u -p
	ssh(ssh_config)
	sshd(sshd_config)

ssh:
	ssh -l USERNAME REMOTE_HOST
	ssh USERNAME@REMOTE_HOST
	ssh root@172.16.0.1 'ifconfig'
		-p
		-X
		-Y
基于密钥的认证
一台主机为客户端（基于某个用户实现）
1、生成一对密钥
	ssh-keygen [-q] [-b bits] -t type [-N new_passphrase] [-C comment] [-f output_keyfile]
	ssh-keygen
		-t {rsa|dsa}
		-f /path/to/keyfile
		-N 'password'
		ssh-keygen -t rsa -C "ministry78@163"
		ssh-keygen -t rsa -f .ssh/id_rsa -N ''
2、将公钥传输至服务器端某家目录下的.shh/authorized_keys文件中
	使用文件传输工具传输（ssh-copy-id,scp）
	ssh-copy-id -i /path/tp/pubkey USERNAME@REMOTE_HOST
		ssh-copy-id -i .ssh/id_rsa.pub root@172.16.100.2
	scp远程传输
	scp [option] SRC DEST
		REMOTE_MACHINE
			USERNAME@HOSTSNAME:/path/to/somefile
		-r -p -a
	cat Identity.pub >> .ssh/authorized_keys	
3、测试登录
	
总结：
1、密码应该经常换且足够复杂；
2、使用非默认端口；
3、限制登录客户地址；
4、禁止管理员直接登录；
5、仅允许有限限制用户登录；
6、使用基于密钥的认证
7、禁止使用版本1
 
