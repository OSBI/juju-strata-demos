#####################################################################
#
# Demo Name: Financial Services Demo - Data Ingest to quasardb
#
# Notes: 
# 
# Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 
#
#####################################################################

# Purpose of the demo

This demo aims at deploying a scalable Key-Value store called [quasardb](http://quasardb.net), then feed it with a stream of financial data provided through a Kafka cluster. 


# Services deployed
## quasardb

quasardb is the datastore we use as a target for the data. It's is a very scalable Key Value store provided by Bureau14, and used in production at several banks and other financial services companies. 

For the purpose of the demo, we'll have only 3 nodes of quasardb deployed, and more can be added during the demo if needed. 

## ZooKeeper

ZK is a service to manage clusters of other services. In our case, the Kafka cluster. In production, we would put at least 3 nodes, but here for the sake of the demo we'll use only a single instance. 

## Kafka

Kafka is a broker of messages open sourced by LinkedIn a while ago. It acts as a scalable pub/sub cluster of data. There are 3 main components in Kafka: 

* Producers: producers collect the data and publish it to the Kafka Cluster
* Brokers: they are the core of the cluster, maintain the list of channels up & running, and provide warranties that no message is ever lost
* Consumers: connect to the cluster and get data out of it, to send it to a sink

### Kafka Producers

We'll have many producters connected. 

* Our existing [kafka-twitter](https://github.com/SaMnCo/charm-kafka-twitter) producer, which code was initially produced by our friends at NFLabs. 
* New code kafka-pubnub that connects to [Pubnub](http://www.pubnub.com)
* Other producers if we have time

### Kafka Cluster

This will be the vanilla Apache Kafka charm maintained by the Canonical Big Data team. The cluster should be made of several nodes, but for this demo purpose we'll also use a single node of Kafka

### Kafka Consumers

We'll have a consumer for each of the channels that our producers produce, and shipping data into quasardb. 

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

	./bin/01-deploy.sh

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
    [Thu Aug 27 13:04:14 CEST 2015] [financedemo] [local0.debug] : Validating dependencies
    [Thu Aug 27 13:04:15 CEST 2015] [financedemo] [local0.debug] : Succesfully switched to quasardb
    [Thu Aug 27 13:04:16 CEST 2015] [financedemo] [local0.info] : quasardb already bootstrapped
    [Thu Aug 27 13:04:17 CEST 2015] [financedemo] [local0.info] : juju-gui already deployed or failed to deploy juju-gui
    [Thu Aug 27 13:04:18 CEST 2015] [financedemo] [local0.info] : Juju GUI now available on https://X.X.X.X with user admin:password
    [Thu Aug 27 13:04:18 CEST 2015] [financedemo] [local0.debug] : Bootstrapping process finished. You can safely move to deployment.

## Deployment

    :~$ ./bin/01-deploy.sh 
    [Thu Aug 27 14:15:37 CEST 2015] [financedemo] [local0.debug] : Validating dependencies
    [Thu Aug 27 14:15:37 CEST 2015] [financedemo] [local0.debug] : Successfully switched to quasardb
    [Thu Aug 27 14:15:38 CEST 2015] [financedemo] [local0.debug] : Succesfully cloned bureau14/qdb-juju-charms.git
    [Thu Aug 27 14:15:52 CEST 2015] [financedemo] [local0.debug] : deployed quasardb-xtp
    [Thu Aug 27 14:15:55 CEST 2015] [financedemo] [local0.debug] : successfully set constraints "mem=2G cpu-cores=2 root-disk=32G" for quasardb-xtp
    [Thu Aug 27 14:16:09 CEST 2015] [financedemo] [local0.debug] : Added 2 units of quasardb-xtp

## Reset

    :~$ ./bin/50-reset.sh 
    [Thu Aug 27 14:09:57 CEST 2015] [financedemo] [local0.debug] : Successfully switched to quasardb
    [Thu Aug 27 14:12:22 CEST 2015] [financedemo] [local0.debug] : Successfully reset quasardb

