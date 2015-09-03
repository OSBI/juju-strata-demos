#!/bin/bash
#####################################################################
#
# Configure Demo
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

# Switching to project 
switchenv "${PROJECT_ID}" 

echo "For the next 3 minutes we will force the emission of logs ever 5 to 10s on the HDFS master"

(for i in `seq 1 1 20` ; do juju ssh hdfs-master/0 logger -t FlumeDemo "Can you see me now `date` ??" 2>/dev/null 1>/dev/null ; sleep 5 ; done) &

echo "Now we list all FlumeData files available..."
juju ssh flume-hdfs/0 hdfs dfs -ls -R /user/flume/flume-syslog

echo "Now copy the link to the latest FlumeData.<id> and run 'juju ssh flume-hdfs/0 hdfs dfs -tail -f <path-to-FlumeData>'"
echo "You should see lines of log that look like 'Sep  3 10:20:58 hdfs-master-0 FlumeDemo: Can you see me??'"