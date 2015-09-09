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
# Deploy Hadoop Environment
# https://jujucharms.com/u/bigdata-dev/apache-hbase/trusty/14
#
#####################################################################

# Deploy HDFS Master
deploy hadoop hadoop-master "mem=4G cpu-cores=4 root-disk=32G"

# Deploy Compute Nodes 
deploy hadoop hadoop-slavecluster "mem=4G cpu-cores=4 root-disk=32G"
add-unit hadoop-slavecluster 2

# Relations
add-relation hadoop-master:namenode hadoop-slavecluster:datanode
add-relation hadoop-master:resourcemanager hadoop-slavecluster:nodemanager


#####################################################################
#
# Deploy Datafari 
#
#####################################################################

# Services
# Download the Git repository for quasardb charm
#cd "${MYDIR}/../tmp"
#git clone https://github.com/"${DATAFARI_CHARM_GIT_REPO}".git 1>/dev/null 2>/dev/null \
#  && log debug Succesfully cloned "${DATAFARI_CHARM_GIT_REPO}".git \
#  || log err Could not clone "${DATAFARI_CHARM_GIT_REPO}".git
#REPO_NAME="$(echo "${DATAFARI_CHARM_GIT_REPO}" | cut -f2 -d'/')"
#DATAFARI_CHARM_REPO="${MYDIR}/../tmp/${REPO_NAME}/charms"
#cd -

# Now deploying Quasardb
#juju deploy --repository "${DATAFARI_CHARM_REPO}" --constraints "${DATAFARI_CONSTRAINTS}" local:"trusty/${DATAFARI_CHARM_NAME}" 2>/dev/null \
#  && log debug deployed ${DATAFARI_CHARM_NAME} \
#  || log crit Could not deploy ${DATAFARI_CHARM_NAME}

# Relations
#add-relation datafari hadoop-master

# Expose
#expose datafari

#until [ "$(get-status datafari)" = "started" ] 
#do 
#	log debug waiting for SpagoBI to be up and running
#	sleep 30
#done

