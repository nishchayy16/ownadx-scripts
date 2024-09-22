# Redis Cluster Key Count Script

## Overview
This script retrieves the key count from each Redis master node in a cluster, sums the counts, and outputs the total to a text file.

## Purpose
The purpose of this script is to provide an easy way to monitor the total number of keys in a Redis cluster by aggregating the key counts from all master nodes.

## Workflow
1. Connect to the specified Redis master node to fetch the cluster configuration.
2. Extract the IP addresses of all master nodes in the cluster.
3. For each master node, retrieve the key count for `db0`.
4. Sum the key counts from all master nodes.
5. Save the total key count to a specified output file.

## Requirements
- `redis-cli` must be installed and accessible in your PATH.

## Usage
   ```bash
   bash path/to/your_script.sh
