#!/bin/bash
#####################################################################
#
# Deploy financial ingest demo
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
log debug Validating dependencies
ensure_cmd_or_install_package_apt git git-all

# Switching to project 
switchenv "${PROJECT_ID}" 

# Download the Git repository for quasardb charm
cd "${MYDIR}/../tmp"
git clone https://github.com/"${QUASARDB_CHARM_GIT_REPO}".git 1>/dev/null 2>/dev/null \
  && log debug Succesfully cloned "${QUASARDB_CHARM_GIT_REPO}".git \
  || log err Could not clone "${QUASARDB_CHARM_GIT_REPO}".git
REPO_NAME="$(echo "${QUASARDB_CHARM_GIT_REPO}" | cut -f2 -d'/')"
QUASARDB_CHARM_REPO="${MYDIR}/../tmp/${REPO_NAME}/charms"
cd -

# Now deploying Quasardb
juju deploy --repository "${QUASARDB_CHARM_REPO}" --constraints "${QUASARDB_CONSTRAINTS}" local:"trusty/${QUASARDB_CHARM_NAME}" 2>/dev/null \
  && log debug deployed ${QUASARDB_CHARM_NAME} \
  || log crit Could not deploy ${QUASARDB_CHARM_NAME}
juju set-constraints --service "${QUASARDB_CHARM_NAME}" "${QUASARDB_CONSTRAINTS}" 2>/dev/null \
  && log debug successfully set constraints \"${QUASARDB_CONSTRAINTS}\" for ${QUASARDB_CHARM_NAME} \
  || log err Could not set constraints for ${QUASARDB_CHARM_NAME}
add-unit "${QUASARDB_CHARM_NAME}" 2

# Now deploying ZK Server
deploy apache-zookeeper zookeeper mem=2G cpu-cores=2

# Now deploying Kafka
deploy cs:~bigdata-dev/trusty/apache-kafka kafka mem=2G cpu-cores=2
# deploy apache-kafka kafka mem=2G cpu-cores=2

# Add relation 
add-relation kafka zookeeper

