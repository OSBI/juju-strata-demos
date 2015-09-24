#!/bin/bash

#################################################################################
#
# This is a big fat hack to upgrade MongoDB to 2.6 so it works.
#
#
#################################################################################
service mongodb stop
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
apt-get update -yqq
apt-get -yqq install mongodb-org unzip
sed -i 's/bind_ip = 127.0.0.1/#bind_ip = 127.0.0.1/g' /etc/mongod.conf
service mongod restart
