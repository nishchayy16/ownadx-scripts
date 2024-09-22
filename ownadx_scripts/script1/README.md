# Redis Memory Monitoring Script

## Overview
This Bash script monitors the memory usage of multiple Redis clusters. If memory consumption exceeds 80%, it triggers actions such as pausing XML ad serving for 5 minutes and sends email alerts. The script also alerts via Zabbix if memory usage crosses 70%. It checks Redis node connectivity and cluster integrity, alerting on failures.

## Purpose
- Monitor Redis cluster memory usage.
- Automatically pause XML adserving for 5 minutes if memory consumption exceeds 80%.
- Send email alerts on memory threshold breaches or connectivity issues.
- Trigger Zabbix alerts if memory usage exceeds 70%.
- Check the integrity of the Redis cluster and alert if any node is out of the cluster.

## Workflow
1. **Memory Monitoring**: Connects to Redis servers via SSH and retrieves memory statistics using the `redis-cli`. 
    - If memory usage exceeds 80%, the script pauses XML adserving by running a cron job and sends an alert email.
    - If memory usage crosses 70%, Zabbix sends an alert for high memory consumption.
2. **Error Handling**: If unable to connect to any Redis node three times, the script pauses XML adserving and sends an alert.
3. **Cluster Integrity Check**: The script checks if each Redis node is part of the cluster and logs any node that is out.

## Requirements
- **Redis CLI**: Must be installed and accessible on the system.
- **Java**: Required to run the cron job that pauses XML adserving.
- **SMTP CLI**: Used for sending email alerts (`smtp-cli` must be installed).

## Usage:
To execute the script, run the following command:

```bash
./redis_memory_monitor.sh
