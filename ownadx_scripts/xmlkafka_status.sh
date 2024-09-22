#!/bin/bash
> /tmp/2.txt
id=`cat /home2/kafka/config/server.properties | grep broker.id | cut -d '=' -f2`
value="/tmp/2.txt"
/home2/zookeeper/bin/zkCli.sh ls /brokers/ids | grep '11, 12, 13, 14, 15, 16, 17, 18, 19, 20' | cut -d ']' -f1 | cut -d '[' -f2 | tr ',' '\n' >> /tmp/2.txt

while test= read -r line
do 

if [[ "$id" == "$line" ]]; then 
	echo '0' > /tmp/kafka_status
	date '+%Y/%m/%d  %HH:%MM'
	echo "`hostname` kafka  in sync"
exit
else
	echo '1' > /tmp/kafka_status
	date '+%Y/%m/%d  %HH:%MM'
	echo "`hostname` kafka out of sync"
fi
done < $value

