#####################################################################
#
# Demo Name: IoT Demo - DeviceHive, Spark, Cassandra, Kafka
#
#####################################################################

Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 

# Purpose of the demo

DeviceHive makes any connected device part of the Internet of Things. It provides the communication layer, control software and multi-platform libraries to bootstrap development of smart energy, home automation, remote sensing, telemetry, remote control and monitoring software, and much more. Leave communications to DeviceHive and focus on product and innovation. Learn more at: http://devicehive.com

# Main Services deployed
## nginx

nginx is used as a Load Balancer and Router between DeviceHive instances. It allows to scale out the deployment. 

## DeviceHive

DeviceHive is the main Java server, which is listening for notifications from connected devices and sends them to Kafka nodes. 

## PostgreSQL

PostgreSQL is used as the default database to store information about the deployment, user authentication, devices, networks and other metadata.

## Kafka Cluster 

Kafka is used to maintain a stream of pubsub messages available at any time. 

## Spark / Zeppelin

Spark Streaming and Zeppelin are used to provide a programming interface to the cluster. 
 
# Data Sources
## Snappy

Data is taken from Ubuntu Snappy devices sending data back to the DeviceHive API. 

## Simulator

The simulator is a script that simulates a device and send values back to the cluster. These values can be "OK Values" and the behavior of the simulated device is OK, or "KO Values" and the cluster will think this device is broken or soon to be broken. 

# Using the demo: Interfaces, GUIs... 
## DeviceHive

The DeviceHive charm is only exposed through nginx. It will answer on port 80 on 2 routes: 

* /admin will provide access to DeviceHive administration panel. Default credentials are dhadmin:dhadmin_#911
* /api is the endpoint to send information back to DeviceHive. 

In order to discover the version of the API and endpoints, you can curl the API: 

    $ curl -s http://X.X.X.X/api/rest/info/
    {
      "apiVersion": "2.0.0",
      "serverTimestamp": "2015-09-08T11:02:28.389",
      "webSocketServerUrl": "ws://X.X.X.X/api/websocket"
    }


## Zeppelin

Zeppelin is a GUI that allows users to code in their browser for Spark and other execution backends (Flink...). It opens an interface on port 8090 by default. You can connect directly on that interface once the service is exposed. 

Once Zeppelin is exposed, you should copy-paste the code in var/zeppelin-code in a new note, then make sure the ZOOKEEPER_HOST is set properly to the URL set in the charm. Then you can run it. 

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
    [Tue Sep 1 12:22:16 CEST 2015] [demo] [local0.debug] : Validating dependencies
    [Tue Sep 1 12:22:16 CEST 2015] [demo] [local0.debug] : Successfully switched to dataart
    [Tue Sep 1 12:27:46 CEST 2015] [demo] [local0.debug] : Succesfully bootstrapped dataart
    [Tue Sep 1 12:28:02 CEST 2015] [demo] [local0.debug] : Successfully deployed juju-gui to machine-0
    [Tue Sep 1 12:28:03 CEST 2015] [demo] [local0.info] : Juju GUI now available on https://52.2.244.223 with user admin:5e8490328953c902094c68c16a88226f
    [Tue Sep 1 12:28:24 CEST 2015] [demo] [local0.debug] : Bootstrapping process finished for dataart. You can safely move to deployment.


## Deployment

    $ ./bin/01-deploy-dataart.sh 
    [Mon Sep 7 16:34:47 CEST 2015] [demo] [local0.debug] : Successfully switched to dataart
    [Mon Sep 7 16:35:03 CEST 2015] [demo] [local0.debug] : Successfully deployed devicehive
    [Mon Sep 7 16:35:08 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2 root-disk=32G" for devicehive
    [Mon Sep 7 16:35:24 CEST 2015] [demo] [local0.debug] : Successfully deployed postgresql
    [Mon Sep 7 16:35:28 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=2G cpu-cores=2 root-disk=32G" for postgresql
    [Mon Sep 7 16:35:51 CEST 2015] [demo] [local0.debug] : Successfully deployed kafka
    [Mon Sep 7 16:35:55 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2 root-disk=32G" for kafka
    [Mon Sep 7 16:35:55 CEST 2015] [demo] [local0.debug] : Successfully added 1 units of kafka
    [Mon Sep 7 16:36:20 CEST 2015] [demo] [local0.debug] : Successfully deployed zookeeper
    [Mon Sep 7 16:36:24 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=2G cpu-cores=2" for zookeeper
    [Mon Sep 7 16:36:40 CEST 2015] [demo] [local0.debug] : Successfully deployed nginx
    [Mon Sep 7 16:36:44 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=2G cpu-cores=2" for nginx
    [Mon Sep 7 16:36:46 CEST 2015] [demo] [local0.debug] : Successfully created relation between zookeeper:ka and kafka:zk
    [Mon Sep 7 16:36:47 CEST 2015] [demo] [local0.crit] : Could not create relation between zookeeper:dh and devicehice:zk
    [Mon Sep 7 16:36:48 CEST 2015] [demo] [local0.debug] : Successfully created relation between kafka:dh and devicehive:ka
    [Mon Sep 7 16:36:52 CEST 2015] [demo] [local0.debug] : Successfully created relation between devicehive:pg and postgresql:dh
    [Mon Sep 7 16:36:53 CEST 2015] [demo] [local0.debug] : Successfully created relation between nginx:dh and devicehive:website
    [Mon Sep 7 16:36:54 CEST 2015] [demo] [local0.debug] : Successfully exposed nginx

 
## Reset

    :~$ ./bin/50-reset.sh 
 

