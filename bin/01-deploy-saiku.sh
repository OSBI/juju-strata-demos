#!/bin/bash
#####################################################################
#
# Deploy financial ingest demo
#
# Notes: 
# 
# Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 
#
#####################################################################

# Validating I am running on debian-like OS
[ -f /etc/debian_version ] || {
	echo "We are not running on a Debian-like system. Exiting..."
	exit 0
}

# Load Configuration
MYNAME="$(readlink -f "$0")"
MYDIR="$(dirname "${MYNAME}")"
MYCONF="${MYDIR}/../etc/demo.conf"
MYLIB="${MYDIR}/../lib/bashlib.sh"
JUJULIB="${MYDIR}/../lib/jujulib.sh"

for file in "${MYCONF}" "${MYLIB}" "${JUJULIB}"; do
	[ -f ${file} ] && source ${file} || { 
		echo "Could not find required files. Exiting..."
		exit 0
	}
done 

# Check install of all dependencies
# log debug Validating dependencies

# Switching to project 
switchenv "${PROJECT_ID}" 

#####################################################################
#
# Deploy HBase Environment
# https://jujucharms.com/u/bigdata-dev/apache-hbase/trusty/14
#
#####################################################################

# Deploy HDFS Master
deploy apache-hadoop-hdfs-master hdfs-master "mem=4G cpu-cores=2 root-disk=32G"

# Deploy YARN 
deploy apache-hadoop-yarn-master yarn-master "mem=2G cpu-cores=2"

# Deploy Compute slaves
deploy apache-hadoop-compute-slave compute-slave "mem=4G cpu-cores=2 root-disk=32G"
add-unit compute-slave 2

# Deploy Hadoop Plugin
deploy apache-hadoop-plugin plugin

# Relations
add-relation yarn-master hdfs-master
add-relation compute-slave yarn-master
add-relation compute-slave hdfs-master
add-relation plugin yarn-master
add-relation plugin hdfs-master

#####################################################################
#
# Deploy Apache Spark 
# https://jujucharms.com/apache-spark/trusty/2
#
#####################################################################

# Services
deploy apache-spark spark "mem=4G cpu-cores=2"

# Relations
add-relation spark plugin

#####################################################################
#
# Deploy Apache Spark Thrift Addon
#
#####################################################################

deploy cs:~f-tom-n/charms/trusty/spark-thrift

run --unit spark/0 "wget http://community.meteorite.bi/store.tgz -P /home/ubuntu" 
run --unit spark/0 "tar xvfz /home/ubuntu/store.tgz -C /home/ubuntu"
run --unit spark/0 "hadoop fs -put store.par /user/ubuntu"
run --unit spark/0 "/usr/lib/spark/bin/beeline -u jdbc:hive2://localhost:10000 -e 'CREATE TEMPORARY TABLE store2 USING org.apache.spark.sql.parquet OPTIONS (path \"/user/ubuntu/store.par\")'"
run --unit spark/0 "/usr/lib/spark/bin/beeline -u jdbc:hive2://localhost:10000 -e 'CREATE TABLE STORE(medallion varchar(250),hack_license varchar(250),vendor_id varchar(250),rate_code int,store_and_fwd_flag varchar(250),pickup_datetime timestamp,dropoff_datetime timestamp,passenger_count int,trip_time_in_secs int,trip_distance double,pickup_longitude double,pickup_latiude double,dropoff_longitude double,dropoff_latitude double,t_id bigint,year int,month int,day int,hour int)'"
run --unit spark/0 "/usr/lib/spark/bin/beeline -u jdbc:hive2://localhost:10000 -e 'insert into table store select * from store2'"

#####################################################################
#
# Deploy single node of MongoDB
# https://jujucharms.com/mongodb/trusty/26
#
#####################################################################

#juju deploy --constraints "mem=4G cpu-cores=2 root-disk=16G" mongodb configsvr --config "${MYDIR}/../etc/mongodb-shard.yaml" -n3
#deploy mongodb mongos
#juju deploy mongodb shard1 --config "${MYDIR}/../etc/mongodb-shard.yaml" -n3
#juju deploy mongodb shard2 --config "${MYDIR}/../etc/mongodb-shard.yaml" -n3
#juju deploy mongodb shard3 --config "${MYDIR}/../etc/mongodb-shard.yaml" -n3

#add-relation mongos:mongos-cfg configsvr:configsvr
#add-relation mongos:mongos shard1:database
#add-relation mongos:mongos shard2:database
#add-relation mongos:mongos shard3:database

deploy mongodb mongodb "mem=4G cpu-cores=2 root-disk=16G"
add-unit mongodb
sleep 60
add-unit mongodb

expose mongodb

#####################################################################
#
# Deploy Saiku Server
# https://jujucharms.com/u/f-tom-n/saikuanalytics/trusty/0 
#
#####################################################################

# Tomcat Server
# https://jujucharms.com/tomcat/trusty/1
deploy tomcat tomcat "mem=8G cpu-cores=4"

# Saiku
deploy cs:~f-tom-n/trusty/saikuanalytics-0 saiku

# Relations
add-relation tomcat saiku
add-relation spark saiku

action do saiku/0 addschema name=spark content="$(cat ./spark_schema.xml)"
action do saiku/0 addschema name=mongo content="$(cat ./mongo_schema.xml)"

# Expose
expose tomcat

