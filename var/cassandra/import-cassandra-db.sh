#!/bin/bash
# Import Script for MongoDB database

WORKLOAD=cassandra
cd /home/ubuntu

cp /root/.cassandra/cqlshrc ./ 
chmod a+rw ./cqlshrc

if [ -f /home/ubuntu/foodmart.${WORKLOAD}.tar.gz ]
then 
	tar xfz /home/ubuntu/foodmart.${WORKLOAD}.tar.gz
	sleep 1
	rm -f /home/ubuntu/foodmart.${WORKLOAD}.tar.gz
fi

C_USERNAME=$(grep "username" /home/ubuntu/cqlshrc | cut -f3 -d' ')
C_PASSWORD=$(grep "password" /home/ubuntu/cqlshrc | cut -f3 -d' ')

cqlsh -u "${C_USERNAME}" -p "${C_PASSWORD}" -f foodmart.${WORKLOAD}

echo "Imported Cassandra& files. See yah!"
