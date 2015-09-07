#!/bin/bash
# Import Script for MySQL database

WORKLOAD=mysql
cd /home/ubuntu
sudo cp /var/lib/mysql/mysql.passwd ./
sudo chmod +r /home/ubuntu/mysql.passwd

[ -f ./foodmart.${WORKLOAD}.tar.gz ] && { tar xfz ./foodmart.${WORKLOAD}.tar.gz ; sleep 1; rm -f ./foodmart.${WORKLOAD}.tar.gz }

mysql -u root -p`cat /var/lib/mysql/mysql.passwd` foodmart_key < foodmart.sql

echo "All done. See yah!"