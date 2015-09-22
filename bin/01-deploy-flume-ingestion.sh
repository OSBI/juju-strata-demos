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

if [ $(is_sudoer) -eq 0 ]; then
	die "You must be root or sudo to run this script"
fi

# Check install of all dependencies
# log debug Validating dependencies

# Switching to project 
switchenv "${PROJECT_ID}" 

#####################################################################
#
# Deploy Hadoop Environment
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
# Deploy Apache Flume 
# https://jujucharms.com/apache-flume-syslog/trusty/1
#
#####################################################################

# Main Agent
deploy apache-flume-hdfs flume-hdfs "mem=7G cpu-cores=2"
add-relation plugin flume-hdfs

# Syslog Flume Agent
deploy apache-flume-syslog flume-syslog
add-relation flume-syslog flume-hdfs

# Add rsyslog connector on some nodes
deploy rsyslog-forwarder-ha rsyslog-forwarder-ha
juju add-relation rsyslog-forwarder-ha hdfs-master
juju add-relation rsyslog-forwarder-ha flume-syslog

#####################################################################
#
# Deploy Apache Spark & Zeppelin
# https://jujucharms.com/apache-zeppelin
# https://jujucharms.com/apache-spark 
#
# Note: Spark has to be 1.3.X for now, so we stick to rev 2. 
#
#####################################################################

# Services
# Note: we still on apache-spark-2 because it's Spark 1.3
deploy apache-spark-2 spark "mem=4G cpu-cores=2"

until [ "$(get-status spark)" = "started" ] 
do 
	log debug waiting for Spark to be up and running
	sleep 30
done

# SPARK_MACHINE_ID=$(juju status spark --format tabular | grep "spark/0" | awk '{ print $5 }')

deploy apache-zeppelin zeppelin

# Relations
add-relation spark plugin 
add-relation spark zeppelin

expose spark
expose zeppelin

sleep 30

ZEPPELIN_IPADDRESS=$(juju status spark/0 --format tabular | grep zeppelin | tail -n1 | awk '{ print $6 }')
log info You can now connect to Zeppelin on http://${ZEPPELIN_IPADDRESS}:9090

