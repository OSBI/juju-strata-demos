#!/bin/bash

# Make sure we have tools
apt-get update -yqq && apt-get install -yqq unzip 

# Download taxi file if not there
cd /home/ubuntu

[ -f trip_fare_1.csv.zip ] || wget -c http://84.40.61.82/trip_fare_1.csv.zip
[ -f trip_fare_1.csv ] || unzip trip_fare_1.csv.zip

# Import data into MongoDB
mongoimport -d taxi -c fares --type csv --file trip_fare_1.csv --headerline

rm -f trip_fare_1.csv.zip trip_fare_1.csv

exit $?