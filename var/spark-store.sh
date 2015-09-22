#!/bin/bash

cd /home/ubuntu

[ -f store.tgz ] || wget -c http://community.meteorite.bi/store.tgz -P /home/ubuntu

[ -d store.par  ] || tar xvfz /home/ubuntu/store.tgz -C /home/ubuntu

su -c "hdfs dfs -put /home/ubuntu/store.par /user/ubuntu" ubuntu

/usr/lib/spark/bin/beeline -u jdbc:hive2://localhost:10000 -e 'CREATE TEMPORARY TABLE store2 USING org.apache.spark.sql.parquet OPTIONS (path "/user/ubuntu/store.par")'

/usr/lib/spark/bin/beeline -u jdbc:hive2://localhost:10000 -e 'CREATE TABLE STORE(medallion varchar(250),hack_license varchar(250),vendor_id varchar(250),rate_code int,store_and_fwd_flag varchar(250),pickup_datetime timestamp,dropoff_datetime timestamp,passenger_count int,trip_time_in_secs int,trip_distance double,pickup_longitude double,pickup_latiude double,dropoff_longitude double,dropoff_latitude double,t_id bigint,year int,month int,day int,hour int)'

/usr/lib/spark/bin/beeline -u jdbc:hive2://localhost:10000 -e 'insert into table store select * from store2'

rm -f store.tgz
rm -rf store.par

cd -

exit $?