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
# Deploy Hive Data
#
#####################################################################

WORKLOAD=hive
TARGET_UNIT="${WORKLOAD}/0"

juju scp "${DATADIR}/${WORKLOAD}/"${DATASET}".${WORKLOAD}.tar.gz" "${DATADIR}/${WORKLOAD}/import-${WORKLOAD}-db.sh" "${TARGET_UNIT}":/home/ubuntu/
juju ssh "${TARGET_UNIT}" sudo /home/ubuntu/import-${WORKLOAD}-db.sh

sleep 5
juju action do spagobi/0 add-datasource unitname="${TARGET_UNIT}" database="default" username="hive" password="password"

# IMPORTANT NOTE: There is a lib versioning issue (SpagoBI runs libthrift-0.7.0.jar and we use libthrift-0.9.0.jar )
# Engineering to update their repo, but in essence the libthrift lib can be downloaded from Hive: 
# juju scp hive/0:/usr/lib/hive/lib/libthrift-0.9.0.jar /tmp/
# Then uploaded on Tomcat
# juju scp /tmp/libthrift-0.9.0.jar tomcat/0:/home/ubuntu
# juju ssh tomcat/0 sudo cp libthrift-0.9.0.jar /home/ubuntu/SpagoBI/lib/
# juju ssh tomcat/0 sudo cp libthrift-0.9.0.jar /usr/share/tomcat7/lib/
# juju ssh tomcat/0 sudo rm -f /usr/share/tomcat7/lib/libthrift-0.7.0.jar /home/ubuntu/SpagoBI/lib/libthrift-0.7.0.jar
# juju ssh tomcat/0 sudo service tomcat7 restart
# See http://stackoverflow.com/questions/30852380/java-nosuchmethoderror-when-connecting-via-jdbc-to-hive for info about the error




#####################################################################
#
# Deploy MySQL Data
#
#####################################################################

WORKLOAD=mysql
TARGET_UNIT="${WORKLOAD}-data-master/0"

juju scp "${DATADIR}/${WORKLOAD}/${DATASET}.${WORKLOAD}.tar.gz" "${DATADIR}/${WORKLOAD}/import-${WORKLOAD}-db.sh" "${TARGET_UNIT}":/home/ubuntu/
juju ssh "${TARGET_UNIT}" sudo /home/ubuntu/import-${WORKLOAD}-db.sh

juju scp "${TARGET_UNIT}":/home/ubuntu/mysql.passwd "${MYDIR}/../tmp/mysql.passwd"
juju ssh "${TARGET_UNIT}" sudo rm -f /home/ubuntu/mysql.passwd

# Note: these are hard coded in the import-mysql-db.sh. Do not change if you don't update the other file. 
M_USERNAME=spagobi
M_PASSWORD=SpagoBI

juju action do spagobi/0 add-datasource unitname="${TARGET_UNIT}" database="${DATASET}_key" username="${M_USERNAME}" password="${M_PASSWORD}"


#####################################################################
#
# Deploy MongoDB Data
#
#####################################################################

WORKLOAD=mongodb
TARGET_UNIT="${WORKLOAD}/0"

juju scp "${DATADIR}/${WORKLOAD}/${DATASET}.${WORKLOAD}.tar.gz" "${DATADIR}/${WORKLOAD}/import-${WORKLOAD}-db.sh" "${TARGET_UNIT}":/home/ubuntu/
juju ssh "${TARGET_UNIT}" sudo /home/ubuntu/import-${WORKLOAD}-db.sh

juju action do spagobi/0 add-datasource unitname="${TARGET_UNIT}" database="${DATASET}" username="" password=""

#####################################################################
#
# Deploy Cassandra Data
#
#####################################################################

WORKLOAD=cassandra
TARGET_UNIT="${WORKLOAD}/0"

juju scp "${DATADIR}/${WORKLOAD}/${DATASET}.${WORKLOAD}.tar.gz" "${DATADIR}/${WORKLOAD}/import-${WORKLOAD}-db.sh" "${TARGET_UNIT}":/home/ubuntu/
juju ssh "${TARGET_UNIT}" sudo /home/ubuntu/import-${WORKLOAD}-db.sh

sleep 5
juju scp "${TARGET_UNIT}":/home/ubuntu/cqlshrc "${MYDIR}/../tmp/cqlshrc"
juju ssh "${TARGET_UNIT}" sudo rm -f /home/ubuntu/cqlshrc

C_USERNAME=$(grep "username" "${MYDIR}/../tmp/cqlshrc" | cut -f3 -d' ')
C_PASSWORD=$(grep "password" "${MYDIR}/../tmp/cqlshrc" | cut -f3 -d' ')

log info Connecting to Cassandra with ${C_USERNAME} and password ${C_PASSWORD}
juju action do spagobi/0 add-datasource unitname="${TARGET_UNIT}" database="${DATASET}" username="${C_USERNAME}" password="${C_PASSWORD}"

#####################################################################
#
# Deploy HBase Data
#
#####################################################################

WORKLOAD=hbase
TARGET_UNIT="${WORKLOAD}-master/0"
juju action do spagobi/0 add-datasource unitname="${TARGET_UNIT}" database="${DATASET}" username="" password=""

juju ssh ${TARGET_UNIT} wget -c "https://s3-us-west-2.amazonaws.com/samnco-static-files/demos/hbase/mapPhoenix.jar"
juju scp "${DATADIR}/${WORKLOAD}/${DATASET}.sql" "${TARGET_UNIT}":/home/ubuntu/

ZK=$(juju pprint | grep "zookeeper/0" | awk '{ print $3 }')

juju ssh ${TARGET_UNIT} java -jar mapPhoenix.jar ${ZK}:2181:/hbase-unsecure

#####################################################################
#
# Deploy PostgreSQL Data
#
#####################################################################

#####################################################################
#
# Spark
#
#####################################################################



