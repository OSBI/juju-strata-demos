#####################################################################
#
# Demo Name: Analytics Demo - Meteorite.bi Saiku on Spark and MongoDB
#
# Notes: 
# 
# Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 
#
#####################################################################

# Purpose of the demo

This demo aims at deploying Saiku and connect it to Spark and MongoDB, to express how easy it is to deploy a very complex data analytics solution with Juju. 

# Main Services deployed
## Saiku

Saiku is the main attraction of this demo, and the center of gravity of all data sources. To deploy it, we install a powerful Tomcat server, and the Saiku subordinate charm, then we connect them together. 

## Hadoop Cluster

We run a simple Hadoop cluster with YARN, made of an HDFS Master + Compute Slaves, to which we attach a YARN Master to orchestrate compute. 

## Spark 

We run a set of Spark nodes managed via YARN on top of our Hadoop Cluster.

## MongoDB

We run a small cluster of MongoDB (only 1 node for this demo), the main noSQL document datastore available. 

# Data Sources

TBD (Tom to provide sources)

# Usage
## Configuration

Edit ./etc/demo.conf to change: 

* PROJECT_ID : This is the name of your environment
* FACILITY (default to local0): Log facility to use for logging demo activity
* LOGTAG (default to demo): A tag to add to log lines to ease recognition of demos
* MIN_LOG_LEVEL (default to debug): change verbosity. Only logs above this in ./etc/syslog-levels will show up

## Bootstrapping 

	./bin/00-bootstrap.sh

Will set up the environment 

## Deploying  

	./bin/01-deploy-saiku.sh

Will deploy the charms required for the demo

## Configure  

	./bin/10-setup.sh

Will configure whatever needs to be configured

## Resetting 

	./bin/50-reset.sh

Will reset the environment but keep it alive

## Clean

	./bin/99-cleanup.sh

Will completely rip of the environment and delete local files

# Sample Outputs
## Bootstrapping

    :~$ ./bin/00-bootstrap.sh 
    [Mon Aug 31 17:34:17 CEST 2015] [demo] [local0.debug] : Validating dependencies
    [Mon Aug 31 17:34:17 CEST 2015] [demo] [local0.debug] : Successfully switched to saiku
    [Mon Aug 31 17:39:19 CEST 2015] [demo] [local0.debug] : Succesfully bootstrapped saiku
    [Mon Aug 31 17:39:32 CEST 2015] [demo] [local0.debug] : Successfully deployed juju-gui to machine-0
    [Mon Aug 31 17:39:34 CEST 2015] [demo] [local0.info] : Juju GUI now available on https://X.X.X.X with user admin:XXX
    [Mon Aug 31 17:39:54 CEST 2015] [demo] [local0.debug] : Bootstrapping process finished for saiku. You can safely move to deployment.


## Deployment

    $ ./bin/01-deploy-saiku.sh 
    [Mon Aug 31 17:56:04 CEST 2015] [demo] [local0.debug] : Successfully switched to saiku
    [Mon Aug 31 17:56:19 CEST 2015] [demo] [local0.debug] : Successfully deployed hdfs-master
    [Mon Aug 31 17:56:23 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2 root-disk=32G" for hdfs-master
    [Mon Aug 31 17:56:40 CEST 2015] [demo] [local0.debug] : Successfully deployed yarn-master
    [Mon Aug 31 17:56:44 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=2G cpu-cores=2" for yarn-master
    [Mon Aug 31 17:57:01 CEST 2015] [demo] [local0.debug] : Successfully deployed compute-slave
    [Mon Aug 31 17:57:06 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2 root-disk=32G" for compute-slave
    [Mon Aug 31 17:57:24 CEST 2015] [demo] [local0.debug] : Successfully added 2 units of compute-slave
    [Mon Aug 31 17:57:29 CEST 2015] [demo] [local0.debug] : Successfully deployed plugin
    [Mon Aug 31 17:57:31 CEST 2015] [demo] [local0.debug] : Successfully created relation between yarn-master and hdfs-master
    [Mon Aug 31 17:57:32 CEST 2015] [demo] [local0.debug] : Successfully created relation between compute-slave and yarn-master
    [Mon Aug 31 17:57:34 CEST 2015] [demo] [local0.debug] : Successfully created relation between compute-slave and hdfs-master
    [Mon Aug 31 17:57:37 CEST 2015] [demo] [local0.debug] : Successfully created relation between plugin and yarn-master
    [Mon Aug 31 17:57:38 CEST 2015] [demo] [local0.debug] : Successfully created relation between plugin and hdfs-master
    [Mon Aug 31 17:57:54 CEST 2015] [demo] [local0.debug] : Successfully deployed spark
    [Mon Aug 31 17:57:58 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2" for spark
    [Mon Aug 31 17:57:59 CEST 2015] [demo] [local0.debug] : Successfully created relation between spark and plugin
    [Mon Aug 31 17:58:16 CEST 2015] [demo] [local0.debug] : Successfully deployed mongodb
    [Mon Aug 31 17:58:20 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2 root-disk=16G" for mongodb
    [Mon Aug 31 17:58:30 CEST 2015] [demo] [local0.debug] : Successfully added 1 units of mongodb
    [Mon Aug 31 17:59:38 CEST 2015] [demo] [local0.debug] : Successfully added 1 units of mongodb
    [Mon Aug 31 17:59:40 CEST 2015] [demo] [local0.debug] : Successfully exposed mongodb
    [Mon Aug 31 17:59:40 CEST 2015] [demo] [local0.debug] : Successfully deployed tomcat
    [Mon Aug 31 17:59:40 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=8G cpu-cores=4" for tomcat
    [Mon Aug 31 17:59:47 CEST 2015] [demo] [local0.debug] : Successfully deployed saiku
    [Mon Aug 31 17:59:49 CEST 2015] [demo] [local0.debug] : Successfully created relation between tomcat and saiku
    [Mon Aug 31 17:59:50 CEST 2015] [demo] [local0.debug] : Successfully exposed tomcat
 

## Reset

    :~$ ./bin/50-reset.sh 
 

