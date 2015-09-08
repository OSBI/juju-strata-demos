#!/bin/bash
# Import Script for MongoDB database

WORKLOAD=hive

cd /home/ubuntu

if [ -f /home/ubuntu/foodmart.${WORKLOAD}.tar.gz ]
then 
	tar xfz /home/ubuntu/foodmart.${WORKLOAD}.tar.gz
	sleep 1
	rm -f /home/ubuntu/foodmart.${WORKLOAD}.tar.gz
fi

su -c "hive -f ${WORKLOAD}.sql" ${WORKLOAD}

for FOLDER in $(grep "LOCATION" ${WORKLOAD}.sql | cut -f2 -d"'")
do 
	FILE="$(echo ${FOLDER} | cut -f4 -d'/')"

	su -c "hdfs dfs -copyFromLocal -f ./${FILE}.csv ${FOLDER}/${FILE}.csv" ${WORKLOAD}

done

echo "Imported Hive files. See yah!"
