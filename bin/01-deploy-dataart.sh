#!/bin/bash
#####################################################################
#
# Deploy IoT Platform demo
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
# Deploy DeviceHive Environment
#
#####################################################################

# Deploy DeviceHive
deploy cs:~x3v947pl/trusty/devicehive devicehive "mem=4G cpu-cores=2 root-disk=32G"

# Deploy PostgreSQL
deploy cs:~x3v947pl/trusty/postgresql-dh postgresql "mem=2G cpu-cores=2 root-disk=32G"

# Deploy Kafka
deploy cs:~x3v947pl/trusty/kafka-dh kafka "mem=4G cpu-cores=2 root-disk=32G"
add-unit kafka

# Deploy ZooKeeper
deploy cs:~x3v947pl/trusty/zookeeper-dh zookeeper "mem=2G cpu-cores=2"

# Deploy nginx
deploy cs:~x3v947pl/trusty/nginx-dh nginx "mem=2G cpu-cores=2"

# Deploy Zeppelin
deploy cs:~x3v947pl/trusty/zeppelin-dh zeppelin --constraints="mem=4G cpu-cores=4"

# Deploy Spark
deploy cs:~x3v947pl/trusty/spark-dh spark --constraints="mem=4G cpu-cores=4"

# Deploy Simulator from Git
# Download the Git repository for quasardb charm
[ -d "${MYDIR}/../tmp/charms/trusty" ] && rm -rf "${MYDIR}/../tmp/charms/trusty/*" \
	|| mkdir -p "${MYDIR}/../tmp/charms/trusty"

cd "${MYDIR}/../tmp/charms/trusty"
git clone https://github.com/"${DHSIMULATOR_CHARM_GIT_REPO}".git "${DHSIMULATOR_CHARM_NAME}" 1>/dev/null 2>/dev/null \
  && log debug Succesfully cloned "${DHSIMULATOR_CHARM_GIT_REPO}".git \
  || log err Could not clone "${DHSIMULATOR_CHARM_GIT_REPO}".git
DHSIMULATOR_CHARM_REPO="${MYDIR}/../tmp/charms"
cd -

# Now deploying Datafari
juju deploy --repository "${DHSIMULATOR_CHARM_REPO}" --constraints "${DHSIMULATOR_CONSTRAINTS}" local:"trusty/${DHSIMULATOR_CHARM_NAME}" 2>/dev/null \
  && log debug deployed ${DHSIMULATOR_CHARM_NAME} \
  || log crit Could not deploy ${DHSIMULATOR_CHARM_NAME}

# Relations
add-relation zookeeper:ka kafka:zk
add-relation devicehive:pg postgresql:dh
add-relation nginx:dh devicehive:website
add-relation zookeeper devicehice
add-relation kafka:dh devicehive:ka
add-relation zeppelin zookeeper
add-relation zeppelin spark
add-relation "${DHSIMULATOR_CHARM_NAME}" devicehive

# Expose
expose nginx
expose zeppelin

