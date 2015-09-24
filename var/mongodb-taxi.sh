#!/bin/bash
# Download taxi file if not there
cd /home/ubuntu

[ -f trip_fare_1.csv.zip ] || wget -c http://84.40.61.82/trip_fare_1.csv.zip
[ -f trip_fare_1.csv ] || unzip trip_fare_1.csv.zip

# Import data into MongoDB
mongoimport -d taxi -c fares --type csv --file trip_fare_1.csv --headerline

mongo taxi --eval "db.fares.ensureIndex({hack_license:1})"
mongo taxi --eval "db.fares.ensureIndex({medallion:1})"
mongo taxi --eval "db.fares.ensureIndex({vendor_id:1})"
mongo taxi --eval "db.fares.ensureIndex({payment_type:1})"
mongo taxi --eval "db.fares.ensureIndex({pickup_datetime:1})"
mongo taxi --eval "db.fares.ensureIndex({day:1})"
mongo taxi --eval "db.fares.ensureIndex({hour:1})"

rm -f trip_fare_1.csv.zip trip_fare_1.csv

exit $?