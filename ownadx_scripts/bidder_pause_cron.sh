#!/bin/bash
## Author: Akshay Bondre 28/09/2022
## Purpose: To check redis memory consumption on xml-redis-clusters and run Avinash's cron to pause xml adserving for 5 min if memory consumption crosses 80% treshold
## Script Dependecy: smtp-cli, java, ssh, configured zabbix UserParameter()
#######################################################################################################################################################################

NAME=(redis-cluster-01 redis-cluster-02 redis-cluster-03 redis-cluster-04 redis-cluster-05 redis-cluster-06)
IPs=(192.168.80.174 192.168.80.175 192.168.80.176 192.168.80.177 192.168.80.178 192.168.80.180)
echo -e "\n######### Checking for: `date +'%d/%m/%Y-%H:%M:%S'` ##########"
num=0
for i in ${NAME[@]}
do
echo -e "\n"
#################### COLLECT DATA xml-redismaster-02 #############################
ssh -q  -o StrictHostKeyChecking=no -o "ConnectTimeout 90"  -i /home2/keys/rediskey vrtzadmin@${IPs[$num]} -p 7559 "redis-cli -p 6379 info memory |egrep 'used_memory_rss:|total_system_memory:'" > /tmp/redis_info.txt
if [ $? -ne 0 ]
then
echo "Error collecting data from $i"
echo 1 >> /tmp/counter
	if [ `cat /tmp/counter |wc -l` -eq 3 ]
	then
		echo "running  bidder pause cron as 3 times no response from $i"
		java -jar /home2/cronjob/spdp-xml/spdp-redis-load-handler.jar >> /home2/cronjob/spdp-xml/spdp-redis-load-handler.log 2>&1
		smtp-cli --server=zimbra.vertoz.com --port 587  --user=csv-monitor@zimbra.vertoz.local --pass=<password> --auth --from='XML-redismaster-01 <awsmonitor@vertoz.com>' --to=devops@vertoz.com --to=sp.mishra@vertoz.com --to=mohsin.shaikh@vertoz.com --to=ajinkyaraj.nayak@techbravo.com --to=avinash.gavanang@vertoz.com --subject="XML Adserving Status" --body-html "Error collecting redis info data from $i from the last three runs.<br><b>Pausing XML Adserving for 5 minutes</b><br> Please review logs for /home2/cronjob/bidder_pause_cron.sh script"
		rm -f /tmp/counter
		exit
	fi
smtp-cli --server=zimbra.vertoz.com --port 587  --user=csv-monitor@zimbra.vertoz.local --pass=<password> --auth --from='XML-redismaster-01 <awsmonitor@vertoz.com>' --to=devops@vertoz.com --to=sp.mishra@vertoz.com --to=avinash.gavanang@vertoz.com --subject="Unable to collect data from $i" --body-plain "Error collecting redis info data from $i. Please review logs for /home2/cronjob/bidder_pause_cron.sh script"
exit
fi
###############################################################


################ DATA PROCESSING ###########################################
VAL1=`cat /tmp/redis_info.txt |grep 'used_memory_rss:' |grep -oE '[0-9]+'`
VAL2=`cat /tmp/redis_info.txt |grep 'total_system_memory:' |grep -oE '[0-9]+'`

USED_MEM=$(( $VAL1 / 1024 / 1024 ))
EIGHTY_PERCENT_MEM=$(( ($VAL2 / 1024 / 1024 / 100 * 80) ))
SEVENTY_PERCENT_MEM=$(( ($VAL2 / 1024 / 1024 / 100 * 70) ))
##############################################################################
echo "Mem Usage $i: $USED_MEM MB"

if [ "$USED_MEM" -ge "$EIGHTY_PERCENT_MEM" ]
then
echo "1" > /tmp/cron_run.txt
echo "Pausing XML Adserving for 5 minutes"
java -jar /home2/cronjob/spdp-xml/spdp-redis-load-handler.jar >> /home2/cronjob/spdp-xml/spdp-redis-load-handler.log 2>&1
smtp-cli --server=zimbra.vertoz.com --port 587  --user=csv-monitor@zimbra.vertoz.local --pass=<password> --auth --from='XML-redismaster-01 <awsmonitor@vertoz.com>' --to=devops@vertoz.com --to=sp.mishra@vertoz.com --to=avinash.gavanang@vertoz.com --to=qa-team@vertoz.com --subject="XML Adserving Stopped" --body-plain "As Memory consumption on $i has crossed 80%. Stopped XML adserving for 5 minutes"
else 
echo "Memory consumption BELOW threshold"
echo "0" > /tmp/cron_run.txt
fi

########################## Zabbix alert for crossing 70 % mem consumption ####################
if [ "$USED_MEM" -ge "$SEVENTY_PERCENT_MEM" ]
then
echo "1" > /tmp/${i}_mem.txt
else 
echo "0" > /tmp/${i}_mem.txt
fi
((num=$num+1 ))
done
################### Logic to check cluster integrity ##################
num1=0
echo -e "\n############ Checking if all nodes are in cluster ############"
for i in ${IPs[@]}
do
redis-cli -h $i -p 6379 cluster nodes > /tmp/cluster_info.txt
grep $i /tmp/cluster_info.txt > /dev/null

if [ $? -ne 0 ]
then
echo "1" > /tmp/${NAME[$num1]}_cluster.txt
echo "${NAME[$num1]} is out of cluster"
else
echo "0" > /tmp/${NAME[$num1]}_cluster.txt
echo "$i All good"
fi
((num1=$num1+1 ))
done
echo -e "\n######## Script Ended at `date +'%d/%m/%Y-%H:%M:%S'` #########"




