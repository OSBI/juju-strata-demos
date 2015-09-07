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
# Deploy DeviceHive Environment
#
#####################################################################

# Deploy DeviceHive
deploy cs:~x3v947pl/trusty/devicehive devicehive "mem=4G cpu-cores=2 root-disk=32G"

# Deploy PostgreSQL
deploy cs:~x3v947pl/trusty/postgresql-dh postgresql "mem=2G cpu-cores=2 root-disk=32G"

# Deploy Kafka
deploy cs:~x3v947pl/trusty/kafka-dh kafka "mem=4G cpu-cores=2 root-disk=32G"

# Deploy ZooKeeper
deploy cs:~x3v947pl/trusty/zookeeper-dh zookeeper "mem=2G cpu-cores=2"

# Deploy nginx
deploy cs:~x3v947pl/trusty/nginx-dh nginx "mem=2G cpu-cores=2"

# Relations
add-relation zookeeper:ka kafka:zk
add-relation zookeeper:dh devicehice:zk
add-relation kafka:dh devicehive:ka
add-relation devicehive:pg postgresql:dh
add-relation nginx:dh devicehive:website

# Expose
expose nginx

