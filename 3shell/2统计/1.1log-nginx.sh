#!/bin/bash
#用shell脚本来分析Nginx负载均衡器的日志，这样可以快速得出排名靠前的网站和IP等，推荐大家使用线上环境下的shell脚本。本节中的shell脚本又分为两种情况，第一种情况是Nginx作为最前端的负载均衡器，其集群架构为Nginx+Keepalived时

if [ $# -eq 0 ]; then
　 echo "Error: please specify logfile."  
　 exit 0
else
	LOG=$1  
fi

if [ ! -f $1 ]; then  
　 echo "Sorry, sir, I can't find this apache log file, pls try again!"  
exit 0
fi
 
####################################################  
echo "Most of the ip:"  
echo "-------------------------------------------"  
awk '{ print$1 }' $LOG| sort| uniq -c| sort -nr| head -10  
echo  
echo  
####################################################  
echo "Most of the time:"  
echo "--------------------------------------------"  
awk '{ print$4 }' $LOG| cut -c 14-18| sort| uniq -c| sort -nr| head -10  
echo  
echo  
####################################################  
echo "Most of the page:"  
echo "--------------------------------------------"  
awk '{print$11}' $LOG| sed 's/^.*\\(.cn*\\)\"/\\1/g'| sort| uniq -c| sort -rn| head -10  
echo  
echo  
####################################################  
echo "Most of the time / Most of the ip:"  
echo "--------------------------------------------"  
awk '{print $4}' $LOG| cut -c 14-18| sort -n| uniq -c| sort -nr| head -10 > timelog
echo timelog  
for i in `awk '{print $2}' timelog` 
do
#	echo $i  
	num=`grep $i timelog| awk '{print $1}'`
	echo "$i $num"  
	ip=`grep $i $LOG|awk '{print $1}'| sort -n| uniq -c| sort -nr| head -10`
	echo "$ip"  
	echo  
done  
rm -f timelog 
