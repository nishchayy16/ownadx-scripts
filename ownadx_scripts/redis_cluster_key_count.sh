#!/bin/bash
## Author: Akshay Bondre
## Purpose: To get key count from individual redis masters present in cluster and combine it

ab=(`redis-cli -h 192.168.80.174 -c cluster nodes |grep master |grep -Po '([0-9]{1,3}\.){3}[0-9]{1,3}'`)
c=0
for i in ${ab[@]}; do b=(`redis-cli -h $i -c -p 6379 info keyspace |grep db0  |cut -d ',' -f1 |cut -d '=' -f2`);c=$(( $c + $b ));done
echo $c > /tmp/redis_cluster_key_count.txt

