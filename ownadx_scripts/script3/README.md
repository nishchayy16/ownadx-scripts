# Kafka Broker ID Sync Check Script

## Overview
This Bash script checks the synchronization status of Kafka broker IDs by comparing the broker ID specified in the Kafka configuration with the broker IDs stored in Zookeeper. It logs the synchronization status to a file for monitoring purposes.

## Purpose
The purpose of this script is to ensure that the Kafka brokers are in sync with the expected broker IDs. It helps in maintaining the integrity of the Kafka cluster by providing a clear status of synchronization, which can be useful for troubleshooting and monitoring.

## Workflow
1. The script clears or creates a temporary file to store broker IDs from Zookeeper.
2. It retrieves the broker ID from the Kafka configuration file.
3. The script queries Zookeeper to list the current broker IDs.
4. It compares the broker ID from the configuration with the IDs retrieved from Zookeeper.
5. Based on the comparison, it logs the synchronization status (`in sync` or `out of sync`) to a designated status file and prints a timestamped message to the console.

## Requirements
- Bash shell
- Access to Kafka configuration file (`server.properties`)
- Access to Zookeeper CLI (`zkCli.sh`)

## Usage
1. To execute the script, run the following command:
```bash
   ./xmlkafka_status.sh
