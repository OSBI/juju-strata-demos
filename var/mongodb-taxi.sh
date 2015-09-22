#!/bin/bash

#################################################################################
#
# This is a big fat hack to upgrade MongoDB to 2.6 so it works.
#
#
#################################################################################
service mongodb stop
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
apt-get update -yqq
apt-get -yqq install mongodb-org unzip
sed -i 's/bind_ip = 127.0.0.1/#bind_ip = 127.0.0.1/g' /etc/mongod.conf
service mongod restart

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