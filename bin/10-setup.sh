#!/bin/bash
#####################################################################
#
# Install Datafari Data
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
DATADIR="${MYDIR}/../var"
DATASET=foodmart

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
# Download Dataset in Hadoop
#
#####################################################################

WORKLOAD=hadoop-master
TARGET_UNIT="${WORKLOAD}/0"

juju scp "${DATADIR}/${WORKLOAD}/"${DATASET}".${WORKLOAD}.tar.gz" "${DATADIR}/${WORKLOAD}/import-${WORKLOAD}-db.sh" "${TARGET_UNIT}":/home/ubuntu/
juju ssh "${TARGET_UNIT}" sudo /home/ubuntu/import-${WORKLOAD}-db.sh

sleep 5
