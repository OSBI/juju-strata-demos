#!/bin/bash
#####################################################################
#
# Install SpagoBI Data
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
# Deploy MySQL Data
#
#####################################################################

WORKLOAD=mysql
TARGET_UNIT="${WORKLOAD}-data-master/0"

juju scp "${DATADIR}/${WORKLOAD}/"${DATASET}".sql.tar.gz" "${DATADIR}/${WORKLOAD}/import-${WORKLOAD}-db.sh" "${TARGET_UNIT}":/home/ubuntu/
juju ssh "${TARGET_UNIT}" sudo /home/ubuntu/import-${WORKLOAD}-db.sh

sleep 5
juju scp "${TARGET_UNIT}":/home/ubuntu/cqlshrc "${MYDIR}/../tmp/mysql.passwd"
juju ssh "${TARGET_UNIT}" sudo rm -f /home/ubuntu/mysql.passwd

M_USERNAME=root
M_PASSWORD=$(cat "${MYDIR}/../tmp/cqlshrc")

juju action do spagobi/0 add-datasource unitname="${TARGET_UNIT}" database="${DATASET}" username="${M_USERNAME}" password="${M_PASSWORD}"


#####################################################################
#
# Deploy MongoDB Data
#
#####################################################################

WORKLOAD=mongodb
TARGET_UNIT="${WORKLOAD}/0"

juju scp "${DATADIR}/${WORKLOAD}/"${DATASET}".${WORKLOAD}.tar.gz" "${DATADIR}/${WORKLOAD}/import-${WORKLOAD}-db.sh" "${TARGET_UNIT}":/home/ubuntu/
juju ssh "${TARGET_UNIT}" sudo /home/ubuntu/import-${WORKLOAD}-db.sh

juju action do spagobi/0 add-datasource unitname="${TARGET_UNIT}" database="${DATASET}" username="" password=""

#####################################################################
#
# Deploy Cassandra Data
#
#####################################################################
DATADIR="/home/scozannet/Documents/canonical/dev/src/strata-demos/var"
WORKLOAD=cassandra
TARGET_UNIT="${WORKLOAD}/0"

juju scp "${DATADIR}/${WORKLOAD}/"${DATASET}".${WORKLOAD}.tar.gz" "${DATADIR}/${WORKLOAD}/import-${WORKLOAD}-db.sh" "${TARGET_UNIT}":/home/ubuntu/
juju ssh "${TARGET_UNIT}" sudo /home/ubuntu/import-${WORKLOAD}-db.sh

sleep 5
juju scp "${TARGET_UNIT}":/home/ubuntu/cqlshrc "${MYDIR}/../tmp/cqlshrc"
juju ssh "${TARGET_UNIT}" sudo rm -f /home/ubuntu/cqlshrc

C_USERNAME=$(grep "username" "${MYDIR}/../tmp/cqlshrc" | cut -f3 -d' ')
C_PASSWORD=$(grep "password" "${MYDIR}/../tmp/cqlshrc" | cut -f3 -d' ')

juju action do spagobi/0 add-datasource unitname="${TARGET_UNIT}" database="${DATASET}" username="${C_USERNAME}" password="${C_PASSWORD}"

#####################################################################
#
# Deploy Hive Data
#
#####################################################################

WORKLOAD=hive
TARGET_UNIT="${WORKLOAD}/0"

juju scp "${DATADIR}/${WORKLOAD}/"${DATASET}".${WORKLOAD}.tar.gz" "${DATADIR}/${WORKLOAD}/import-${WORKLOAD}-db.sh" "${TARGET_UNIT}":/home/ubuntu/
juju ssh "${TARGET_UNIT}" sudo /home/ubuntu/import-${WORKLOAD}-db.sh

sleep 5
juju action do spagobi/0 add-datasource unitname="${TARGET_UNIT}" database="${DATASET}" username="" password=""