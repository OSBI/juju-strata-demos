#!/bin/bash
#####################################################################
#
# Deploy Datafari demo
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
# Upload dataset
#
#####################################################################

juju scp ${MYDIR}/../var/dataset.tar.gz hadoop-master/0:/home/ubuntu/
juju ssh hadoop-master/0 tar xvfz /home/ubuntu/dataset.tar.gz
juju ssh hadoop-master/0 sudo su -c 'hdfs dfs -put /home/ubuntu/dataset /' ubuntu

#####################################################################
#
# Start Crawler
#
#####################################################################

juju action do datafari/0 craw

