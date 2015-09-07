#!/bin/bash
# Import Script for MongoDB database

WORKLOAD=cassandra
cd /home/ubuntu

C_USERNAME=$(grep "username" /root/.cassandra/cqlshrc | cut -f3 -d' ')
C_PASSWORD=$(grep "password" /root/.cassandra/cqlshrc | cut -f3 -d' ')

cp /root/.cassandra/cqlshrc ./ && chmod +r ./cqlshrc

[ -f "./foodmart.${WORKLOAD}.tar.gz" ] && { tar xfz "./foodmart.${WORKLOAD}.tar.gz" ; sleep 1; rm -f "./foodmart.${WORKLOAD}.tar.gz"; }

cqlsh -u "${C_USERNAME}" -p "${C_PASSWORD}" -f foodmart.${WORKLOAD}

echo "Imported Cassandra& files. See yah!"
