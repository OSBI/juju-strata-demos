#####################################################################
#
# Demo Name: Analytics Demo - Meteorite.bi [Saiku](http://www.meteorite.bi/products/saiku) on [Spark](http://spark.apache.org/) and [MongoDB](https://www.mongodb.org/)
#
#####################################################################

Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 

  * [Purpose of the demo](#purpose-of-the-demo)
  * [Main Services deployed](#main-services-deployed)
    * [Saiku](#saiku)
    * [Hadoop Cluster](#hadoop-cluster)
    * [Spark](#spark)
    * [MongoDB](#mongodb)
  * [Data Sources](#data-sources)
  * [Usage](#usage)
    * [Configuration](#configuration)
    * [Bootstrapping](#bootstrapping)
    * [Deploying](#deploying)
    * [Configure](#configure)
    * [Resetting](#resetting)
    * [Clean](#clean)
  * [Access to GUIs](#access-to-guis)
    * [Saiku](#saiku-1)
      * [Login procedure](#login-procedure)
      * [Main GUI](#main-gui)
      * [MongDB Analytics](#mongdb-analytics)
      * [Spark Analytics](#spark-analytics)
      * [Dashboards](#dashboards)
    * [MongoDB](#mongodb-1)
    * [Spark](#spark-1)
  * [Sample Outputs](#sample-outputs)
    * [Bootstrapping](#bootstrapping-1)
    * [Deployment](#deployment)
    * [Reset](#reset)


# Purpose of the demo

This demo aims at deploying [Saiku](http://www.meteorite.bi/products/saiku) and connect it to [Spark](http://spark.apache.org/) and [MongoDB](https://www.mongodb.org/), to express how easy it is to deploy a very complex data analytics solution with Juju. 

# Main Services deployed
## Saiku

[Saiku](http://www.meteorite.bi/products/saiku) is the main attraction of this demo, and the center of gravity of all data sources. To deploy it, we install a powerful Tomcat server, and the [Saiku](http://www.meteorite.bi/products/saiku) subordinate charm, then we connect them together. 

[Saiku](http://www.meteorite.bi/products/saiku) comes in 2 flavours
* Community Edition, that is free and doesn't have all features available
* Enterprise Edition, that unlocks advanced features of the OLAP analysis. 

In our demo, we will use [Saiku](http://www.meteorite.bi/products/saiku) EE, that provides a lot more options and is "the real thing"

## Hadoop Cluster

We run a simple Hadoop cluster with YARN, made of an HDFS Master + Compute Slaves, to which we attach a YARN Master to orchestrate compute. 

## Spark

We run a set of [Spark](http://spark.apache.org/) nodes managed via YARN on top of our Hadoop Cluster.

## [MongoDB](https://www.mongodb.org/)

We run a small cluster of [MongoDB](https://www.mongodb.org/) (3 nodes for this demo), the main noSQL document datastore available. 

# Data Sources

* taxi fares: We deploy a set of [taxi fare](http://84.40.61.82/trip_fare_1.csv.zip) data to [MongoDB](https://www.mongodb.org/). This is similar to what you would find in an operational dataset for a Mongo cluster that backed a webservice or taxi logging data store. The data is fare information for NYC taxi's in Jan 2013 and allows users to perform cost/spend analysis over the data.
* taxi trips: [Spark](http://spark.apache.org/) (HDFS) is fed with taxi journey information. This is intended to simulate a larger data set of semi structured data that would be stored in a HDFS cluster. The taxi journey includes information about the pickup point, drop off point, time taken etc to allow users to perform trip analysis.

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

# Access to GUIs
## Juju GUI

The workload should look like 

![](https://github.com/SaMnCo/juju-strata-demos/blob/saiku/var/screenshots/juju-gui-001.png)

## Saiku 
### Login procedure

[Saiku](http://www.meteorite.bi/products/saiku) is a Java application running on top of Tomcat. First you need to find the IP address of Tomcat by running: 

    juju status tomcat/0 --format tabular

Then browse to http://<TOMCAT_IP_ADDRESS>:8080 to land on the login page: 

![](https://github.com/SaMnCo/juju-strata-demos/blob/saiku/var/screenshots/saiku-gui-001.png)

The default credentials are admin:admin

* If [Saiku](http://www.meteorite.bi/products/saiku) complains that you don't have a license, it means you didn't upload and install the license. You need to have a valid license.lic file and run

    juju scp /path/to/license.lic saiku/0:/tmp/
    juju action do saiku/0 addlicense oatg=/tmp/license.lic

* If [Saiku](http://www.meteorite.bi/products/saiku) complains that an admin session is already opened, it means someone else is already using the GUI. You need to clear the other session to login. Proceed. 

### Main GUI

You should land on the main GUI page: 

![](https://github.com/SaMnCo/juju-strata-demos/blob/saiku/var/screenshots/saiku-gui-002.png)

### MongDB Analytics

TBD

![](https://github.com/SaMnCo/juju-strata-demos/blob/saiku/var/screenshots/saiku-gui-003.png)


### Spark Analytics

TBD

![](https://github.com/SaMnCo/juju-strata-demos/blob/saiku/var/screenshots/saiku-gui-004.png)


### Dashboards

TBD

![](https://github.com/SaMnCo/juju-strata-demos/blob/saiku/var/screenshots/saiku-gui-005.png)

## MongoDB

By default [MongoDB](https://www.mongodb.org/) will not protect the access to data. We can therefore just connect on the server mongodb/0 and enter into the shell using the command "mongo":

    $ mongo
    MongoDB shell version: 2.4.9
    connecting to: test
    > 

We can now look at our databases: 

    > show dbs;
    admin  (empty)
    local  2.078GB
    taxi   3.952GB

Let us dig into this

    > use taxi;
    switched to db taxi
    > show collections;
    fares
    system.indexes

If we take a quick look at our source file: 

    $ head -n10 trip_fare_1.csv
    "medallion", "hack_license", "vendor_id", "pickup_datetime", "payment_type", "fare_amount", "surcharge", "mta_tax", "tip_amount", "tolls_amount", "total_amount", "day", "hour"
    "89D227B655E5C82AECF13C3F540D4CF4","BA96DE419E711691B9445D6A6307C170","CMT","2013-01-01 15:11:48","CSH",6.50,0.00,0.50,0.00,0.00,7.00,1,15
    "0BD7C8F5BA12B88E0B67BED28BEA73D8","9FD8F69F0804BDB5549F40E9DA1BE472","CMT","2013-01-06 00:18:35","CSH",6.00,0.50,0.50,0.00,0.00,7.00,6,0
    "0BD7C8F5BA12B88E0B67BED28BEA73D8","9FD8F69F0804BDB5549F40E9DA1BE472","CMT","2013-01-05 18:49:41","CSH",5.50,1.00,0.50,0.00,0.00,7.00,5,18
    "DFD2202EE08F7A8DC9A57B02ACB81FE2","51EE87E3205C985EF8431D850C786310","CMT","2013-01-07 23:54:15","CSH",5.00,0.50,0.50,0.00,0.00,6.00,7,23
    "DFD2202EE08F7A8DC9A57B02ACB81FE2","51EE87E3205C985EF8431D850C786310","CMT","2013-01-07 23:25:03","CSH",9.50,0.50,0.50,0.00,0.00,10.50,7,23
    "20D9ECB2CA0767CF7A01564DF2844A3E","598CCE5B9C1918568DEE71F43CF26CD2","CMT","2013-01-07 15:27:48","CSH",9.50,0.00,0.50,0.00,0.00,10.00,7,15
    "496644932DF3932605C22C7926FF0FE0","513189AD756FF14FE670D10B92FAF04C","CMT","2013-01-08 11:01:15","CSH",6.00,0.00,0.50,0.00,0.00,6.50,8,11
    "0B57B9633A2FECD3D3B1944AFC7471CF","CCD4367B417ED6634D986F573A552A62","CMT","2013-01-07 12:39:18","CSH",34.00,0.00,0.50,0.00,4.80,39.30,7,12
    "2C0E91FF20A856C891483ED63589F982","1DA2F6543A62B8ED934771661A9D2FA0","CMT","2013-01-07 18:15:47","CSH",5.50,1.00,0.50,0.00,0.00,7.00,7,18

One of the interesting metrics could be to look at how many rides are taken per hour. We can sort the fares: 

    > db.fares.find({ hour: 3 })
    { "_id" : ObjectId("560012e88a6c5d38637ad598"), "medallion" : "7E3256C342CAFB3C23D3ABB98B9F3FB6", "hack_license" : "4F7873C913735088F9BEF85C1D054D31", "vendor_id" : "CMT", "pickup_datetime" : "2013-01-05 03:00:46", "payment_type" : "CSH", "fare_amount" : 21, "surcharge" : 0.5, "mta_tax" : 0.5, "tip_amount" : 0, "tolls_amount" : 0, "total_amount" : 22, "day" : 5, "hour" : 3 }
    { "_id" : ObjectId("560012e88a6c5d38637ad59c"), "medallion" : "CD9DEF073BAB75B8B36015D85FD3F777", "hack_license" : "80430F0667E3C82E63AAF4F0DC547664", "vendor_id" : "CMT", "pickup_datetime" : "2013-01-05 03:20:28", "payment_type" : "CSH", "fare_amount" : 32.5, "surcharge" : 0.5, "mta_tax" : 0.5, "tip_amount" : 0, "tolls_amount" : 0, "total_amount" : 33.5, "day" : 5, "hour" : 3 }
    { "_id" : ObjectId("560012e88a6c5d38637ad5e0"), "medallion" : "5E162F2D7F569949769648C56A23C525", "hack_license" : "6F7932F2B112DAABF1F2A385FE2AB819", "vendor_id" : "CMT", "pickup_datetime" : "2013-01-08 03:13:19", "payment_type" : "CSH", "fare_amount" : 26.5, "surcharge" : 0.5, "mta_tax" : 0.5, "tip_amount" : 0, "tolls_amount" : 0, "total_amount" : 27.5, "day" : 8, "hour" : 3 }
    { "_id" : ObjectId("560012e88a6c5d38637ad5ed"), "medallion" : "8C019CD008A70CC21058D22CF873E42E", "hack_license" : "EC35D26CEE8BBC5FAD8653358C7C194E", "vendor_id" : "CMT", "pickup_datetime" : "2013-01-08 03:50:07", "payment_type" : "CSH", "fare_amount" : 5, "surcharge" : 0.5, "mta_tax" : 0.5, "tip_amount" : 0, "tolls_amount" : 0, "total_amount" : 6, "day" : 8, "hour" : 3 }
    { "_id" : ObjectId("560012e88a6c5d38637ad6ae"), "medallion" : "E0AA965A6EF756AD2C5FBF64E5257F3C", "hack_license" : "ED9ED73AF728A04C7B221AB0408F34E8", "vendor_id" : "VTS", "pickup_datetime" : "2013-01-13 03:58:00", "payment_type" : "CSH", "fare_amount" : 82.5, "surcharge" : 0.5, "mta_tax" : 0.5, "tip_amount" : 0, "tolls_amount" : 0, "total_amount" : 83.5, "day" : 13, "hour" : 3 }

Or just count them: 

    > db.fares.count({ hour: 3 })
    101506
    > db.fares.count({ hour: 18 })
    355464

So yeah, there are 3 times as many taxi rides at 6PM than there are at 3AM. Surely not on Saturday nights but it's a start :). The rest will be done in the [Saiku](http://www.meteorite.bi/products/saiku) GUI 

For more information refer to the [MongoDB documentation](http://docs.mongodb.org/manual/reference/mongo-shell/)

## Spark 

[Spark](http://spark.apache.org/) is an engine that tends to replace Map Reduce (and other things) in the Hadoop ecosystem. It is said to run about 100x faster than MR, due mostly to optimizations in the management of I/Os. 

The first thing we can do with [Spark](http://spark.apache.org/) is compute some decimals of Pi. From your Juju client, run


    $ juju ssh spark/0 spark-submit --class org.apache.spark.examples.SparkPi \ --master yarn-client /usr/lib/spark/lib/spark-examples*.jar 10
    Spark assembly has been built with Hive, including Datanucleus jars on classpath
    Pi is roughly 3.1385                                                                                                                                      

If you expose the [Spark](http://spark.apache.org/) Charm you can also have a look on port 18080. 

    $ juju expose spark
    $ juju status spark/0 --format tabular

then browse to http://<SPARK_IP_ADDRESS>:18080 and have a look at the recent jobs run in Spark. 

![](https://github.com/SaMnCo/juju-strata-demos/blob/saiku/var/screenshots/spark-gui-001.png)

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
 

