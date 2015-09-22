#!/bin/bash
#####################################################################
#
# Saiku Demo Script. Don't run until Saiku Server is responsive and 
# you have a valid license on the server in /tmp/license.lic
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

##################################################
#
# Deploy license to Saiku.
# This license should already have been scp'd to /tmp/license.lic
#
##################################################

juju scp "${MYDIR}/../var/licence.lic" saiku/0:/tmp/license.lic
juju action do saiku/0 addlicense path=/tmp/license.lic

###################################################
#
# Deploy Spark Thrift schema 
#
###################################################

juju scp "${MYDIR}/../var/spark-store.sh" spark/0:/home/ubuntu/
juju run spark/0 sudo /home/ubuntu/spark-store.sh

###################################################
#
# Deploy MongoDB schema 
#
###################################################

juju scp "${MYDIR}/../var/mongodb-taxi.sh" mongodb/0:/home/ubuntu/
juju run mongodb/0 "sudo /home/ubuntu/mongodb-taxi.sh"

###################################################
#
#
# Deploy Demo Schema, Data Source and Reports
#
#
###################################################

SPARK_PRIVATE_IPADDRESS=$(juju run --unit spark/0 "hostname -i")

juju action do saiku/0 addschema name=spark content="$(cat ${MYDIR}/../var/spark_schema.xml)"

juju action do saiku/0 adddatasource content="type=OLAP\nname=taxi\ndriver=mondrian.olap4j.MondrianOlap4jDriver\nlocation=jdbc:mondrian:Jdbc=jdbc:hive2://${SPARK_PRIVATE_IPADDRESS}:10000;Catalog=mondrian:///datasources/spark.xml;JdbcDrivers=org.apache.hive.jdbc.HiveDriver;\nusername=admin\npassword=admin\n"

juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/demo_1.saiku)" path="/homes/home:admin/demo_1.saiku"

MONGODB_PRIVATE_IPADDRESS=$(juju run --unit mongodb/0 "hostname -i")

juju action do saiku/0 addschema name=mongo content="$(cat ${MYDIR}/../var/mongo_schema.xml)"

juju action do saiku/0 addmongoschema content="$(sed -e s/MONGODB_HOST/${MONGODB_PRIVATE_IPADDRESS}/g ${MYDIR}/../var/mongo_db)"

juju action do saiku/0 adddatasource content="type=OLAP\nname=taxi-mongo\ndriver=mondrian.olap4j.MondrianOlap4jDriver\nlocation=jdbc:mondrian:Jdbc=jdbc:calcite:model=mongo:///etc/mongoschema/taxi;Catalog=mondrian:///datasources/mongo.xml;JdbcDrivers=net.hydromatic.optiq.jdbc.Driver;\nusername=admin\npassword=admin"