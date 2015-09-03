#!/bin/bash
#####################################################################
#
# Deploy Demo
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

# Deploy HDFS 
deploy apache-hadoop-hdfs-master hdfs-master "mem=7G cpu-cores=2 root-disk=32G"
deploy apache-hadoop-hdfs-secondary secondary-namenode "mem=7G cpu-cores=2 root-disk=32G"

add-relation hdfs-master secondary-namenode
# Deploy YARN 
deploy apache-hadoop-yarn-master yarn-master "mem=7G cpu-cores=2"

# Deploy Compute slaves
deploy apache-hadoop-compute-slave compute-slave "mem=3G cpu-cores=2 root-disk=32G"
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

# Deploy Spark
deploy apache-spark spark "mem=3G cpu-cores=2"

# Relations
add-relation spark plugin

# Deploy Zeppelin
deploy apache-zeppelin zeppelin 
# Relations
add-relation spark zeppelin
# Expose
expose zeppelin

# Deploy Notebook
deploy cs:~bigdata-dev/trusty/apache-spark-notebook notebook 
# Relations
add-relation spark notebook
# Expose
expose notebook

