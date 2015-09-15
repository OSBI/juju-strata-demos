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
#
# Deploy license to Saiku.
# This license should already have been scp'd to /tmp/license.lic
#
#
##################################################

action do saiku/0 addlicense path=/tmp/license.lic

###################################################
#
#
# Deploy Demo Schema, Data Source and Reports
#
#
#
###################################################
action do saiku/0 addschema name=spark content="$(cat ../demo_files/spark_schema.xml)"

action do saiku/0 adddatasource content="type=OLAP\nname=taxi\ndriver=mondrian.olap4j.MondrianOlap4jDriver\nlocation=jdbc:mondrian:Jdbc=jdbc:hive2://10.0.3.194:10000;Catalog=mondrian:///datasources/spark.xml;JdbcDrivers=org.apache.hive.jdbc.HiveDriver;\nusername=admin\npassword=admin\n"

action do saiku/0 addreport content="$(cat ../demo_files/demo_1.saiku)" path="/homes/home:admin/demo_1.saiku"
#action do saiku/0 addschema name=mongo content="$(cat ./mongo_schema.xml)"
