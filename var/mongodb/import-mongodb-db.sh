#!/bin/bash
# Import Script for MongoDB database

WORKLOAD=mongodb
cd /home/ubuntu

if [ -f /home/ubuntu/foodmart.${WORKLOAD}.tar.gz ]
then 
	tar xfz /home/ubuntu/foodmart.${WORKLOAD}.tar.gz
	sleep 1
	rm -f /home/ubuntu/foodmart.${WORKLOAD}.tar.gz
fi

mongoimport --db foodmart --collection product --type csv --headerline --file product.csv
mongoimport --db foodmart --collection product_class --type csv --headerline --file product_class.csv
mongoimport --db foodmart --collection inventory_fact_1998 --type csv --headerline --file inventory_fact_1998.csv
mongoimport --db foodmart --collection store --type csv --headerline --file store.csv
mongoimport --db foodmart --collection time_by_day --type csv --headerline --file time_by_day.csv

echo "Imported MongoDB files. See yah!"
