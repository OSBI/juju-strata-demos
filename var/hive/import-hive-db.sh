#!/bin/bash
# Import Script for MongoDB database

WORKLOAD=hive

cd /home/ubuntu

[ -f "./foodmart.${WORKLOAD}.tar.gz" ] && { tar xfz "./foodmart.${WORKLOAD}.tar.gz" ; sleep 1; rm -f "./foodmart.${WORKLOAD}.tar.gz"; }

su -c "hive -f ${WORKLOAD}.sql" ${WORKLOAD}

for FOLDER in $(grep "LOCATION" ${WORKLOAD}.sql | cut -f2 -d"'")
do 
	FILE="$(echo ${FOLDER} | cut -f4 -d'/')"

	su -c "hdfs dfs -copyFromLocal -f ./${FILE}.csv ${FOLDER}/${FILE}.csv" ${WORKLOAD}

done

echo "Imported Cassandra& files. See yah!"
