#!/bin/bash
#####################################################################
#
# Deploy SpagoBI Multi Datasource demo
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

if [ $(is_sudoer) -eq 0 ]; then
	die "You must be root or sudo to run this script"
fi

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

# Now deploying ZK Server
deploy apache-zookeeper zookeeper mem=2G cpu-cores=2
add-unit zookeeper 2

# Deploy Compute slaves
deploy apache-hadoop-compute-slave compute-slave "mem=4G cpu-cores=2 root-disk=32G"

# Deploy Hadoop Plugin
deploy apache-hadoop-plugin plugin

# Deploy HBase
deploy cs:~bigdata-dev/trusty/apache-hbase hbase-master "mem=4G cpu-cores=2"
deploy cs:~bigdata-dev/trusty/apache-hbase hbase-regionserver "mem=4G cpu-cores=2"


# Relations
add-relation yarn-master hdfs-master
add-relation compute-slave yarn-master
add-relation compute-slave hdfs-master
add-relation plugin yarn-master
add-relation plugin hdfs-master
add-relation hbase-master plugin
add-relation hbase-regionserver plugin
add-relation zookeeper hbase-master
add-relation zookeeper hbase-regionserver
add-relation hbase-master:master hbase-regionserver:regionserver

# Available services
expose hbase-master

#####################################################################
#
# Deploy Hive 
# https://jujucharms.com/u/bigdata-dev/apache-hive/trusty/44
#
#####################################################################

# Services
deploy apache-hive hive "mem=2G cpu-cores=2"
deploy mysql mysql-hive
juju set mysql-hive binlog-format=ROW

# Relations
add-relation hive plugin
add-relation hive mysql-hive

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
# Deploy MySQL Server (for Data only, not metadata)
# https://jujucharms.com/mysql/trusty/28
#
#####################################################################

deploy mysql mysql-data-master "mem=2G cpu-cores=2 root-disk=12G"

#####################################################################
#
# Deploy PostGreSQL Server (for Data only)
# https://jujucharms.com/postgresql/trusty/27
#
#####################################################################

deploy postgresql postgresql-data-master "mem=2G cpu-cores=2 root-disk=12G"

#####################################################################
#
# Deploy 3 nodes of Cassandra
# https://jujucharms.com/cassandra/trusty/3
#
#####################################################################

deploy cassandra cassandra "mem=4G cpu-cores=2"
add-unit cassandra 2

#####################################################################
#
# Deploy single node of MongoDB
# https://jujucharms.com/mongodb/trusty/26
#
#####################################################################

deploy mongodb mongodb "mem=4G cpu-cores=2"
expose mongodb

#####################################################################
#
# Deploy SpagoBI Server 
#
#####################################################################

# Tomcat Server
# https://jujucharms.com/tomcat/trusty/1
deploy tomcat tomcat "mem=8G cpu-cores=4"

# MySQL for metadata
deploy mysql mysql-metadata 

# SpagoBI
deploy cs:~ana-tomic/trusty/spagobi spagobi

# Relations for metadata
add-relation tomcat spagobi
add-relation spagobi:metadatadb mysql-metadata:db

until [ "$(get-status spagobi)" = "started" ] 
do 
	log debug waiting for SpagoBI to be up and running
	sleep 30
done

# Expose
expose tomcat

#####################################################################
#
# Deploy relation with Data Sources 
#
#####################################################################

# Create relation with Data Sources
add-relation spagobi:mysqlds mysql-data-master
add-relation spagobi:mongodbds mongodb
add-relation spagobi:hiveds hive
add-relation spagobi:cassandrads cassandra
add-relation spagobi:hbaseds hbase-master:hbase
add-relation spagobi:postgresqlds postgresql-data-master:db

