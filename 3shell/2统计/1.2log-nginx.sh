#!/bin/bash
# 用shell脚本来分析Nginx负载均衡器的日志，这样可以快速得出排名靠前的网站和IP等第二种情况是以Nginx作为Web端，置于LVS后面，这时要剔除掉LVS的IP地址，比如LVS服务器的公网IP地址(像203.93.236.141、203.93.236.145等)。这样可以将第一种情况的脚本略微调整一下，如下所示：

if [ $# -eq 0 ]; then
　 echo "Error: please specify logfile."  
　 exit 0
else
	file=$1
	read -p "剔除掉LVS的IP地址vip is:" vip
	cat $file|egrep -v "$vip" > LOG
fi

if [ ! -f $1 ]; then  
　 echo "Sorry, sir, I can't find this apache log file, pls try again!"  
exit 0
fi
 
####################################################  
echo "Most of the ip:"  
echo "-------------------------------------------"  
awk '{ print$1 }' LOG| sort| uniq -c| sort -nr| head -10  
echo  
echo  
####################################################  
echo "Most of the time:"  
echo "--------------------------------------------"  
awk '{ print$4 }' LOG| cut -c 14-18| sort| uniq -c| sort -nr| head -10  
echo  
echo  
####################################################  
echo "Most of the page:"  
echo "--------------------------------------------"  
awk '{print$11}' LOG| sed 's/^.*\\(.cn*\\)\"/\\1/g'| sort| uniq -c| sort -rn| head -10  
echo  
echo  
####################################################  
echo "Most of the time / Most of the ip:"  
echo "--------------------------------------------"  
awk '{print $4}' LOG| cut -c 14-18| sort -n| uniq -c| sort -nr| head -10 > timelog
echo timelog  
for i in `awk '{print $2}' timelog` 
do
#	echo $i  
	num=`grep $i timelog| awk '{print $1}'`
	echo "$i $num"  
	ip=`grep $i LOG|awk '{print $1}'| sort -n| uniq -c| sort -nr| head -10`
	echo "$ip"  
	echo  
done  
rm -f timelog LOG 
