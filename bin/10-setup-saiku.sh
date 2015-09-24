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


juju scp "${MYDIR}/../var/license.lic" saiku/0:/tmp/license.lic
juju action do saiku/0 addlicense path="/tmp/license.lic"

###################################################
#
# Deploy Spark Thrift schema 
#
###################################################

juju scp "${MYDIR}/../var/spark-store.sh" spark/0:/home/ubuntu/
juju ssh spark/0 sudo /home/ubuntu/spark-store.sh

###################################################
#
# Deploy MongoDB schema 
#
###################################################

for i in $(seq 1 1 2); 
do
	juju scp "${MYDIR}/../var/mongodb-upgrade.sh" mongodb/$i:/home/ubuntu/
	juju ssh mongodb/$i "sudo /home/ubuntu/mongodb-upgrade.sh"
done

juju scp "${MYDIR}/../var/mongodb-taxi.sh" mongodb/0:/home/ubuntu/
juju ssh mongodb/0 "sudo /home/ubuntu/mongodb-taxi.sh"

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

juju action do saiku/0 adddatasource content="type=OLAP\nname=taxi-mongo\ndriver=mondrian.olap4j.MondrianOlap4jDriver\nlocation=jdbc:mondrian:Jdbc=jdbc:calcite:model=mongo:///etc/mongoschema/taxi;Catalog=mondrian:///datasources/mongo.xml;JdbcDrivers=org.apache.calcite.jdbc.Driver;\nusername=admin\npassword=admin"

juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_fare_amount_by_day.saiku)" path="/homes/home:admin/avg_fare_amount_by_day.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_p_count_by_day_mdx.saiku)" path="/homes/home:admin/avg_p_count_by_day_mdx.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_p_count_by_day_rotate.saiku)" path="/homes/home:admin/avg_p_count_by_day_rotate.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_p_count_by_day.saiku)" path="/homes/home:admin/avg_p_count_by_day.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_p_count_by_hour_rotate.saiku)" path="/homes/home:admin/avg_p_count_by_hour_rotate.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_p_count_by_hour.saiku)" path="/homes/home:admin/avg_p_count_by_hour.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_t_dist_by_day_rotate.saiku)" path="/homes/home:admin/avg_t_dist_by_day_rotate.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_t_dist_by_day.saiku)" path="/homes/home:admin/avg_t_dist_by_day.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_t_dist_by_hour.saiku)" path="/homes/home:admin/avg_t_dist_by_hour.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_tip_amount_by_day.saiku)" path="/homes/home:admin/avg_tip_amount_by_day.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_total_amount_by_day.saiku)" path="/homes/home:admin/avg_total_amount_by_day.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_trip_time_by_day_rotate.saiku)" path="/homes/home:admin/avg_trip_time_by_day_rotate.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_trip_time_by_day.saiku)" path="/homes/home:admin/avg_trip_time_by_day.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/avg_trip_time_by_hour.saiku)" path="/homes/home:admin/avg_trip_time_by_hour.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/max_tips_waterfall.saiku)" path="/homes/home:admin/max_tips_waterfall.saiku"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/daily_averages_dash.sdb)" path="/homes/home:admin/daily_averages_dash.sdb"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/hourly_averages_dash2.sdb)" path="/homes/home:admin/hourly_averages_dash2.sdb"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/hourly_averages_dash.sdb)" path="/homes/home:admin/hourly_averages_dash.sdb"
juju action do saiku/0 addreport content="$(cat ${MYDIR}/../var/fare_info.sdb)" path="/homes/home:admin/fare_info.sdb"
juju action do saiku/0 warmcache cubeconnection=taxi cubecatalog=Spark cubeschema=Spark cubename="Taxi" query="WITH SET [~ROWS] AS {[Time].[Day].[Day].Members} SELECT NON EMPTY {[Measures].[Avg Passenger Count]} ON COLUMNS, NON EMPTY [~ROWS] ON ROWS FROM [Taxi]"
juju action do saiku/0 warmcache cubeconnection=taxi cubecatalog=Spark cubeschema=Spark cubename="Taxi" query="WITH SET [~COLUMNS] AS {[Time].[Day].[Day].Members} SET [~ROWS] AS {[Time].[Hour].[All Hour]} SELECT NON EMPTY [~COLUMNS] ON COLUMNS, NON EMPTY CrossJoin({[Measures].[Avg Passenger Count]}, [~ROWS]) ON ROWS FROM [Taxi]"
juju action do saiku/0 warmcache cubeconnection=taxi cubecatalog=Spark cubeschema=Spark cubename="Taxi" query="WITH SET [~ROWS] AS {[Time].[Hour].[Hour].Members}SELECTNON EMPTY {[Measures].[Avg Passenger Count]} ON COLUMNS,NON EMPTY [~ROWS] ON ROWSFROM [Taxi]"
juju action do saiku/0 warmcache cubeconnection=taxi cubecatalog=Spark cubeschema=Spark cubename="Taxi" query="WITH SET [~COLUMNS] AS {[Time].[Hour].[Hour].Members} SET [~ROWS] AS {[Time].[Day].[All Day]} SELECT NON EMPTY [~COLUMNS] ON COLUMNS, NON EMPTY CrossJoin({[Measures].[Avg Passenger Count]}, [~ROWS]) ON ROWS FROM [Taxi]"
juju action do saiku/0 warmcache cubeconnection=taxi cubecatalog=Spark cubeschema=Spark cubename="Taxi" query="WITH SET [~ROWS] AS {[Time].[Day].[Day].Members} SELECT NON EMPTY {[Measures].[Avg Trip Distance]} ON COLUMNS, NON EMPTY [~ROWS] ON ROWS FROM [Taxi]"
juju action do saiku/0 warmcache cubeconnection=taxi cubecatalog=Spark cubeschema=Spark cubename="Taxi" query="WITH SET [~ROWS] AS {[Time].[Hour].[Hour].Members} SELECT NON EMPTY {[Measures].[Avg Trip Distance]} ON COLUMNS, NON EMPTY [~ROWS] ON ROWS FROM [Taxi]"
juju action do saiku/0 warmcache cubeconnection=taxi-mongo cubecatalog="Taxi Fares" cubeschema="Taxi Fares" cubename="Fares" query="WITH SET [~ROWS] AS {[Time].[Day].[Day].Members} SELECT NON EMPTY {[Measures].[Average Tip Amount]} ON COLUMNS,NON EMPTY [~ROWS] ON ROWS FROM [Fares]"
juju action do saiku/0 warmcache cubeconnection=taxi-mongo cubecatalog="Taxi Fares" cubeschema="Taxi Fares" cubename="Fares" query="WITH SET [~ROWS] AS {[Time].[Day].[Day].Members} SELECT NON EMPTY {[Measures].[Average Total Amount]} ON COLUMNS, NON EMPTY [~ROWS] ON ROWS FROM [Fares]"
juju action do saiku/0 warmcache cubeconnection=taxi cubecatalog=Spark cubeschema=Spark cubename="Taxi" query="WITH SET [~ROWS] AS {[Time].[Day].[Day].Members} SELECT NON EMPTY {[Measures].[Avg Trip Time(secs)]} ON COLUMNS, NON EMPTY [~ROWS] ON ROWS FROM [Taxi]"
juju action do saiku/0 warmcache cubeconnection=taxi cubecatalog=Spark cubeschema=Spark cubename="Taxi" query="WITH SET [~ROWS] AS {[Time].[Hour].[Hour].Members} SELECT NON EMPTY {[Measures].[Avg Trip Time(secs)]} ON COLUMNS, NON EMPTY [~ROWS] ON ROWS FROM [Taxi]"
juju action do saiku/0 warmcache cubeconnection=taxi-mongo cubecatalog="Taxi Fares" cubeschema="Taxi Fares" cubename="Fares" query="WITH SET [~ROWS] AS {[Fares].[Payment Type].[Payment Type].Members} SELECT NON EMPTY {[Measures].[Max Tip Amount]} ON COLUMNS, NON EMPTY [~ROWS] ON ROWS FROM [Fares]"

