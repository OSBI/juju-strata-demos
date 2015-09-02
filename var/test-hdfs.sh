#!/bin/bash

hdfs dfs -mkdir -p /tmp/hdfs-test
hdfs dfs -chmod -R 777 /tmp/hdfs-test
hdfs dfs -ls /tmp # verify the newly created hdfs-test subdirectory exists
hdfs dfs -rm -R /tmp/hdfs-test
hdfs dfs -ls /tmp # verify the hdfs-test subdirectory has been removed
exit