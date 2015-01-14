#ipvsadm
	管理集群服务
		添加： -A|E -t|u|f service-address [-s scheduler]
			-t: TCP协议的集群
			-u:UDP协议的集群
				service-address: IP:PORT
			-f:FWM: 防火墙标记
				service-address: Mark Number
		修改:-e
		删除:ipvsadm -D -t|u|f service-address
		
		#ipvsadm -A -t 10.0.13.1:80 -s rr
		
	管理集群服务中的RS
		添加:ipvsadm -a -t|u|f service-address -r server-address [options]
		
  ipvsadm -d -t|u|f service-address -r server-address