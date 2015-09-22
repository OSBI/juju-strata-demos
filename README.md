#####################################################################
#
# Demo Name: [Hadoop](http://hadoop.apache.org/) + [Flume](http://flume.apache.org/) Syslog Sink Functionnality
#
#####################################################################

Maintainer: Kevin Monroe @kwmonroe


  * [Demo Name: <a href="http://hadoop.apache.org/">Hadoop</a>   <a href="http://flume.apache.org/">Flume</a> Syslog Sink Functionnality](#demo-name-hadoop--flume-syslog-sink-functionnality)
  * [Purpose of the demo](#purpose-of-the-demo)
  * [Main Services deployed](#main-services-deployed)
    * [Hadoop Cluster](#hadoop-cluster)
    * [Flume](#flume)
    * [Spark](#spark)
    * [Zeppelin](#zeppelin)
  * [Usage](#usage)
    * [Configuration](#configuration)
    * [Bootstrapping](#bootstrapping)
    * [Deploying](#deploying)
    * [Demos](#demos)
      * [HDFS Demo](#hdfs-demo)
      * [Terasort demo](#terasort-demo)
      * [Delete Terasort content](#delete-terasort-content)
      * [Syslog demo](#syslog-demo)
    * [Using the Zeppelin GUI](#using-the-zeppelin-gui)
      * [Access to the GUI](#access-to-the-gui)
    * [Resetting](#resetting)
    * [Clean](#clean)
  * [Sample Outputs](#sample-outputs)
    * [Bootstrapping](#bootstrapping-1)
    * [Deployment](#deployment)
    * [HDFS Run](#hdfs-run)
    * [Terasort Run](#terasort-run)
    * [Delete Terasort Data](#delete-terasort-data)
    * [Syslog Reading](#syslog-reading)
    * [Reset](#reset)
  * [Known Issues](#known-issues)
    * [Syslog Reading](#syslog-reading-1)

# Purpose of the demo

This demo deploys [Flume](http://flume.apache.org/) to ingest syslog data to [HDFS](http://hadoop.apache.org/), and test the functionality through various setups.

What we want to demonstrate is the ease of integration of a log collection system based on [Hadoop](http://hadoop.apache.org/) with existing nodes in the system. [Flume](http://flume.apache.org/) will act as a collector of nodes syslogs (in the example we only process the [HDFS](http://hadoop.apache.org/) master logs but any number of nodes could be added), and ship them to an [HDFS](http://hadoop.apache.org/) sink. 

From there, you can imagine many scenarios where the data gets analysed in real time or batch. We do not go further than collecting the data. 

The original blog post for this demo is available [here](https://github.com/juju-solutions/bigdata-community/blob/gh-pages/_drafts/syslog-analytics-with-apache-hadoop-flume.md)

# Main Services deployed
## [Hadoop](http://hadoop.apache.org/) Cluster

In this example the [Hadoop](http://hadoop.apache.org/) Cluster is production ready. It has 2 [HDFS](http://hadoop.apache.org/) namenodes (master & secondary), 3 compute slaves and a YARN Master. 

It can scale out by adding more compute-slave units.

## [Flume](http://flume.apache.org/) 

[Flume](http://flume.apache.org/) is deployed with 3 subsystems: 

* flume-hdfs, that connects a [Flume](http://flume.apache.org/) stream to a [HDFS](http://hadoop.apache.org/) sink, 
* flume-syslog, that can take care of syslog data 
* rsyslogforward-ha, which is not directly a [Flume](http://flume.apache.org/) component but is used to forward syslog to our cluster. 

## [Spark](http://spark.apache.org/)

[Spark](http://spark.apache.org/) is used here as a computing engine to do analytics on top of logs collected. 

## [Zeppelin](https://zeppelin.incubator.apache.org/)

[Zeppelin](https://zeppelin.incubator.apache.org/) is a notebook system edited by NFLabs. It allows to write and run code from your browser, on top of various compute engines, such as [Spark](http://spark.apache.org/) or Flink. 

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

	./bin/01-deploy-flmume-ingestion.sh

Will deploy the charms required for the demo

You should have a GUI looking like 

![](https://github.com/SaMnCo/juju-strata-demos/blob/flume-ingestion/var/screenshots/juju-gui-001.png)

## Demos  

All the scripts starting in "1X-XXXXXXX.sh" are demo scripts you can run

### [HDFS](http://hadoop.apache.org/) demo

    ./bin/10-run-hdfs.sh

This is a simple demo that shows we can manipulate [HDFS](http://hadoop.apache.org/) via CLI

    $ ./bin/10-run-hdfs.sh 
    [Wed Sep 2 18:24:59 CEST 2015] [demo] [local0.debug] : Successfully switched to canonical
    Warning: Permanently added 'X.X.X.X' (ECDSA) to the list of known hosts.
    Warning: Permanently added 'X.X.X.X' (ECDSA) to the list of known hosts.
    Found 3 items
    drwxr-xr-x   - hdfs   supergroup          0 2015-09-02 16:05 /tmp/hadoop
    drwxrwxrwt   - hdfs   supergroup          0 2015-09-02 16:05 /tmp/hadoop-yarn
    drwxrwxrwx   - ubuntu supergroup          0 2015-09-02 16:25 /tmp/hdfs-test
    15/09/02 16:25:15 INFO fs.TrashPolicyDefault: Namenode trash configuration: Deletion interval = 0 minutes, Emptier interval = 0 minutes.
    Deleted /tmp/hdfs-test
    Found 2 items
    drwxr-xr-x   - hdfs supergroup          0 2015-09-02 16:05 /tmp/hadoop
    drwxrwxrwt   - hdfs supergroup          0 2015-09-02 16:05 /tmp/hadoop-yarn
    Connection to X.X.X.X closed.


### Terasort demo

    ./bin/11-run-terasort.sh

This runs terasort on our bundle.

    $ ./bin/11-run-terasort.sh 
 
### Delete Terasort content

    ./bin/12-delete-terasort.sh

This deletes the output of the previous terasort demo. 

    $ ./bin/12-delete-terasort.sh 
 

### Syslog demo

    ./bin/13-read-syslog.sh

This is interactive as the automation would be complex. The script will show a link to a file that contains the syslog data emitted by [Flume](http://flume.apache.org/). The user will then be asked to manually run a command (link provided) in order to check that data has really been sent to [HDFS](http://hadoop.apache.org/). 

    $ ./bin/13-read-syslog.sh
 
## Using the [Zeppelin](https://zeppelin.incubator.apache.org/) GUI
### Access to the GUI

You can find the [Zeppelin](https://zeppelin.incubator.apache.org/) GUI by running

    $ juju status zeppelin/0 --format tabular | grep zeppelin | tail -n1 | awk '{ print $6 }'

Then connecting on http://ZEPPELIN_IP:9090

This should give you access to 

![](https://github.com/SaMnCo/juju-strata-demos/blob/flume-ingestion/var/screenshots/zeppelin-gui-001.png)

From there you can hit the *[Zeppelin](https://zeppelin.incubator.apache.org/) Flume / HDFS Tutorial* and get to 

![](https://github.com/SaMnCo/juju-strata-demos/blob/flume-ingestion/var/screenshots/juju-gui-002.png)

There you need to save the list of interpreters available, and you can thenhit the "play" button to have the demo run and display nice results. 

Of course your can do the same for other demos. 

## Resetting 

	./bin/50-reset.sh

Will reset the environment but keep it alive

## Clean

	./bin/99-cleanup.sh

Will completely rip of the environment and delete local files

# Sample Outputs
## Bootstrapping

    :~$ ./bin/00-bootstrap.sh 
    [Thu Sep 3 11:04:27 CEST 2015] [demo] [local0.debug] : Validating dependencies
    [Thu Sep 3 11:04:27 CEST 2015] [demo] [local0.debug] : Successfully switched to flume
    [Thu Sep 3 11:08:44 CEST 2015] [demo] [local0.debug] : Succesfully bootstrapped flume
    [Thu Sep 3 11:08:56 CEST 2015] [demo] [local0.debug] : Successfully deployed juju-gui to machine-0
    [Thu Sep 3 11:08:57 CEST 2015] [demo] [local0.info] : Juju GUI now available on https://52.19.197.123 with user admin:5516592232a5069a05e33f4ed75f508d
    [Thu Sep 3 11:09:12 CEST 2015] [demo] [local0.debug] : Bootstrapping process finished for flume. You can safely move to deployment.

## Deployment

    :~$ ./bin/01-deploy-flume-ingestion.sh 
    [Thu Sep 3 11:54:29 CEST 2015] [demo] [local0.debug] : Successfully switched to flume
    [Thu Sep 3 11:54:41 CEST 2015] [demo] [local0.debug] : Successfully deployed hdfs-master
    [Thu Sep 3 11:54:44 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=7G cpu-cores=2 root-disk=32G" for hdfs-master
    [Thu Sep 3 11:54:57 CEST 2015] [demo] [local0.debug] : Successfully deployed secondary-namenode
    [Thu Sep 3 11:55:00 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=7G cpu-cores=2 root-disk=32G" for secondary-namenode
    [Thu Sep 3 11:55:01 CEST 2015] [demo] [local0.debug] : Successfully created relation between hdfs-master and secondary-namenode
    [Thu Sep 3 11:55:14 CEST 2015] [demo] [local0.debug] : Successfully deployed yarn-master
    [Thu Sep 3 11:55:17 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=7G cpu-cores=2" for yarn-master
    [Thu Sep 3 11:55:30 CEST 2015] [demo] [local0.debug] : Successfully deployed compute-slave
    [Thu Sep 3 11:55:33 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=3G cpu-cores=2 root-disk=32G" for compute-slave
    [Thu Sep 3 11:55:47 CEST 2015] [demo] [local0.debug] : Successfully added 2 units of compute-slave
    [Thu Sep 3 11:55:52 CEST 2015] [demo] [local0.debug] : Successfully deployed plugin
    [Thu Sep 3 11:55:53 CEST 2015] [demo] [local0.debug] : Successfully created relation between yarn-master and hdfs-master
    [Thu Sep 3 11:55:56 CEST 2015] [demo] [local0.debug] : Successfully created relation between compute-slave and yarn-master
    [Thu Sep 3 11:55:57 CEST 2015] [demo] [local0.debug] : Successfully created relation between compute-slave and hdfs-master
    [Thu Sep 3 11:55:58 CEST 2015] [demo] [local0.debug] : Successfully created relation between plugin and yarn-master
    [Thu Sep 3 11:56:00 CEST 2015] [demo] [local0.debug] : Successfully created relation between plugin and hdfs-master
    [Thu Sep 3 11:56:11 CEST 2015] [demo] [local0.debug] : Successfully deployed flume-hdfs
    [Thu Sep 3 11:56:14 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=7G cpu-cores=2" for flume-hdfs
    [Thu Sep 3 11:56:15 CEST 2015] [demo] [local0.debug] : Successfully created relation between plugin and flume-hdfs
    [Thu Sep 3 11:56:29 CEST 2015] [demo] [local0.debug] : Successfully deployed flume-syslog
    [Thu Sep 3 11:56:30 CEST 2015] [demo] [local0.debug] : Successfully created relation between flume-syslog and flume-hdfs
    [Thu Sep 3 11:56:30 CEST 2015] [demo] [local0.debug] : Successfully deployed rsyslog-forwarder-ha
    [Thu Sep 3 11:56:31 CEST 2015] [demo] [local0.debug] : Successfully created relation between rsyslog-forwarder-ha and hdfs-master
    [Thu Sep 3 11:56:32 CEST 2015] [demo] [local0.debug] : Successfully created relation between rsyslog-forwarder-ha and flume-syslog

## [HDFS](http://hadoop.apache.org/) Run

    $ ./bin/10-run-hdfs.sh 
    [Thu Sep 3 12:03:59 CEST 2015] [demo] [local0.debug] : Successfully switched to flume
    Found 3 items
    drwxr-xr-x   - hdfs   supergroup          0 2015-09-03 10:00 /tmp/hadoop
    drwxrwxrwt   - hdfs   supergroup          0 2015-09-03 10:00 /tmp/hadoop-yarn
    drwxrwxrwx   - ubuntu supergroup          0 2015-09-03 10:04 /tmp/hdfs-test
    15/09/03 10:04:17 INFO fs.TrashPolicyDefault: Namenode trash configuration: Deletion interval = 0 minutes, Emptier interval = 0 minutes.
    Deleted /tmp/hdfs-test
    Found 2 items
    drwxr-xr-x   - hdfs supergroup          0 2015-09-03 10:00 /tmp/hadoop
    drwxrwxrwt   - hdfs supergroup          0 2015-09-03 10:00 /tmp/hadoop-yarn

## Terasort Run

    $ ./bin/11-run-terasort.sh 
    [Thu Sep 3 12:05:02 CEST 2015] [demo] [local0.debug] : Successfully switched to flume
    15/09/03 10:05:13 INFO client.RMProxy: Connecting to ResourceManager at yarn-master-0/X.X.X.X:8032
    15/09/03 10:05:14 INFO terasort.TeraSort: Generating 1000000 using 3
    15/09/03 10:05:14 INFO mapreduce.JobSubmitter: number of splits:3
    15/09/03 10:05:14 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1441274481493_0001
    15/09/03 10:05:14 INFO impl.YarnClientImpl: Submitted application application_1441274481493_0001
    15/09/03 10:05:14 INFO mapreduce.Job: The url to track the job: http://yarn-master-0:8088/proxy/application_1441274481493_0001/
    15/09/03 10:05:14 INFO mapreduce.Job: Running job: job_1441274481493_0001
    15/09/03 10:05:23 INFO mapreduce.Job: Job job_1441274481493_0001 running in uber mode : false
    15/09/03 10:05:23 INFO mapreduce.Job:  map 0% reduce 0%
    15/09/03 10:05:30 INFO mapreduce.Job:  map 33% reduce 0%
    15/09/03 10:05:31 INFO mapreduce.Job:  map 67% reduce 0%
    15/09/03 10:05:32 INFO mapreduce.Job:  map 100% reduce 0%
    15/09/03 10:05:32 INFO mapreduce.Job: Job job_1441274481493_0001 completed successfully
    15/09/03 10:05:32 INFO mapreduce.Job: Counters: 31
        File System Counters
            FILE: Number of bytes read=0
            FILE: Number of bytes written=279861
            FILE: Number of read operations=0
            FILE: Number of large read operations=0
            FILE: Number of write operations=0
            [HDFS](http://hadoop.apache.org/): Number of bytes read=252
            [HDFS](http://hadoop.apache.org/): Number of bytes written=100000000
            [HDFS](http://hadoop.apache.org/): Number of read operations=12
            [HDFS](http://hadoop.apache.org/): Number of large read operations=0
            [HDFS](http://hadoop.apache.org/): Number of write operations=6
        Job Counters 
            Launched map tasks=3
            Other local map tasks=3
            Total time spent by all maps in occupied slots (ms)=17810
            Total time spent by all reduces in occupied slots (ms)=0
            Total time spent by all map tasks (ms)=17810
            Total vcore-seconds taken by all map tasks=17810
            Total megabyte-seconds taken by all map tasks=18237440
        Map-Reduce Framework
            Map input records=1000000
            Map output records=1000000
            Input split bytes=252
            Spilled Records=0
            Failed Shuffles=0
            Merged Map outputs=0
            GC time elapsed (ms)=257
            CPU time spent (ms)=5630
            Physical memory (bytes) snapshot=532885504
            Virtual memory (bytes) snapshot=2472456192
            Total committed heap usage (bytes)=296747008
        org.apache.hadoop.examples.terasort.TeraGen$Counters
            CHECKSUM=2148987642402270
        File Input Format Counters 
            Bytes Read=0
        File Output Format Counters 
            Bytes Written=100000000
    15/09/03 10:05:53 INFO terasort.TeraSort: starting
    15/09/03 10:05:54 INFO input.FileInputFormat: Total input paths to process : 3
    Spent 138ms computing base-splits.
    Spent 2ms computing TeraScheduler splits.
    Computing input splits took 141ms
    Sampling 3 splits of 3
    Making 3 from 99999 sampled records
    Computing parititions took 845ms
    Spent 989ms computing partitions.
    15/09/03 10:05:55 INFO client.RMProxy: Connecting to ResourceManager at yarn-master-0/X.X.X.X:8032
    15/09/03 10:05:56 INFO mapreduce.JobSubmitter: number of splits:3
    15/09/03 10:05:56 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1441274481493_0002
    15/09/03 10:05:56 INFO impl.YarnClientImpl: Submitted application application_1441274481493_0002
    15/09/03 10:05:56 INFO mapreduce.Job: The url to track the job: http://yarn-master-0:8088/proxy/application_1441274481493_0002/
    15/09/03 10:05:56 INFO mapreduce.Job: Running job: job_1441274481493_0002
    15/09/03 10:06:03 INFO mapreduce.Job: Job job_1441274481493_0002 running in uber mode : false
    15/09/03 10:06:03 INFO mapreduce.Job:  map 0% reduce 0%
    15/09/03 10:06:11 INFO mapreduce.Job:  map 33% reduce 0%
    15/09/03 10:06:15 INFO mapreduce.Job:  map 67% reduce 0%
    15/09/03 10:06:16 INFO mapreduce.Job:  map 100% reduce 0%
    15/09/03 10:06:19 INFO mapreduce.Job:  map 100% reduce 67%
    15/09/03 10:06:21 INFO mapreduce.Job:  map 100% reduce 100%
    15/09/03 10:06:21 INFO mapreduce.Job: Job job_1441274481493_0002 completed successfully
    15/09/03 10:06:21 INFO mapreduce.Job: Counters: 49
        File System Counters
            FILE: Number of bytes read=43312639
            FILE: Number of bytes written=87217353
            FILE: Number of read operations=0
            FILE: Number of large read operations=0
            FILE: Number of write operations=0
            [HDFS](http://hadoop.apache.org/): Number of bytes read=100000384
            [HDFS](http://hadoop.apache.org/): Number of bytes written=100000000
            [HDFS](http://hadoop.apache.org/): Number of read operations=18
            [HDFS](http://hadoop.apache.org/): Number of large read operations=0
            [HDFS](http://hadoop.apache.org/): Number of write operations=6
        Job Counters 
            Launched map tasks=3
            Launched reduce tasks=3
            Data-local map tasks=3
            Total time spent by all maps in occupied slots (ms)=25771
            Total time spent by all reduces in occupied slots (ms)=19612
            Total time spent by all map tasks (ms)=25771
            Total time spent by all reduce tasks (ms)=19612
            Total vcore-seconds taken by all map tasks=25771
            Total vcore-seconds taken by all reduce tasks=19612
            Total megabyte-seconds taken by all map tasks=26389504
            Total megabyte-seconds taken by all reduce tasks=20082688
        Map-Reduce Framework
            Map input records=1000000
            Map output records=1000000
            Map output bytes=102000000
            Map output materialized bytes=43336637
            Input split bytes=384
            Combine input records=0
            Combine output records=0
            Reduce input groups=1000000
            Reduce shuffle bytes=43336637
            Reduce input records=1000000
            Reduce output records=1000000
            Spilled Records=2000000
            Shuffled Maps =9
            Failed Shuffles=0
            Merged Map outputs=9
            GC time elapsed (ms)=741
            CPU time spent (ms)=20330
            Physical memory (bytes) snapshot=1467170816
            Virtual memory (bytes) snapshot=5009379328
            Total committed heap usage (bytes)=966262784
        Shuffle Errors
            BAD_ID=0
            CONNECTION=0
            IO_ERROR=0
            WRONG_LENGTH=0
            WRONG_MAP=0
            WRONG_REDUCE=0
        File Input Format Counters 
            Bytes Read=100000000
        File Output Format Counters 
            Bytes Written=100000000
    15/09/03 10:06:21 INFO terasort.TeraSort: done

## Delete Terasort Data

    $ ./bin/12-delete-terasort.sh 
    [Thu Sep 3 12:09:38 CEST 2015] [demo] [local0.debug] : Successfully switched to flume
    15/09/03 10:09:44 INFO fs.TrashPolicyDefault: Namenode trash configuration: Deletion interval = 0 minutes, Emptier interval = 0 minutes.
    Deleted /user/ubuntu/tera_demo_out

## Syslog Reading

    $ ./bin/13-read-syslog.sh 
    [Thu Sep 3 12:34:46 CEST 2015] [demo] [local0.debug] : Successfully switched to flume
    For the next 3 minutes we will force the emission of logs ever 5 to 10s on the [HDFS](http://hadoop.apache.org/) master
    Now we list all [Flume](http://flume.apache.org/)Data files available...
    drwxr-xr-x   - flume supergroup          0 2015-09-03 10:10 /user/flume/flume-syslog/15-09-03
    drwxr-xr-x   - flume supergroup          0 2015-09-03 10:31 /user/flume/flume-syslog/15-09-03/10
    -rw-r--r--   3 flume supergroup        607 2015-09-03 10:11 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275054285
    -rw-r--r--   3 flume supergroup        981 2015-09-03 10:17 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275404446
    -rw-r--r--   3 flume supergroup        988 2015-09-03 10:18 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275458441
    -rw-r--r--   3 flume supergroup        663 2015-09-03 10:19 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275520432
    -rw-r--r--   3 flume supergroup        299 2015-09-03 10:19 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275554886
    -rw-r--r--   3 flume supergroup        663 2015-09-03 10:21 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275661839
    -rw-r--r--   3 flume supergroup       1100 2015-09-03 10:24 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275886923
    -rw-r--r--   3 flume supergroup        799 2015-09-03 10:25 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275886924
    -rw-r--r--   3 flume supergroup       1084 2015-09-03 10:25 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926097
    -rw-r--r--   3 flume supergroup       1116 2015-09-03 10:25 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926098
    -rw-r--r--   3 flume supergroup       1071 2015-09-03 10:25 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926099
    -rw-r--r--   3 flume supergroup       1185 2015-09-03 10:26 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926100
    -rw-r--r--   3 flume supergroup       1120 2015-09-03 10:26 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926101
    -rw-r--r--   3 flume supergroup       1084 2015-09-03 10:26 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926102
    -rw-r--r--   3 flume supergroup       1116 2015-09-03 10:26 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926103
    -rw-r--r--   3 flume supergroup       1071 2015-09-03 10:27 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926104
    -rw-r--r--   3 flume supergroup       1185 2015-09-03 10:27 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926105
    -rw-r--r--   3 flume supergroup       1120 2015-09-03 10:27 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926106
    -rw-r--r--   3 flume supergroup       1084 2015-09-03 10:27 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926107
    -rw-r--r--   3 flume supergroup       1007 2015-09-03 10:28 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441275926108
    -rw-r--r--   3 flume supergroup       1084 2015-09-03 10:30 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441276197408
    -rw-r--r--   3 flume supergroup       1116 2015-09-03 10:30 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441276197409
    -rw-r--r--   3 flume supergroup       1071 2015-09-03 10:30 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441276197410
    -rw-r--r--   3 flume supergroup        601 2015-09-03 10:31 /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441276197411
    Connection to X.X.X.X closed.
    Now copy the link to the latest [Flume](http://flume.apache.org/)Data.<id> and run 'juju ssh flume-hdfs/0 hdfs dfs -tail -f <path-to-[Flume](http://flume.apache.org/)Data>'
    You should see lines of log that look like 'Sep  3 10:20:58 hdfs-master-0 [Flume](http://flume.apache.org/)Demo: Can you see me??'

    $ juju ssh flume-hdfs/0 hdfs dfs -cat /user/flume/flume-syslog/15-09-03/10/[Flume](http://flume.apache.org/)Data.1441276197410
    <38>Sep  3 10:30:18 hdfs-master-0 sshd[23587]: Accepted publickey for ubuntu from 172.31.20.146 port 55588 ssh2: RSA 52:90:a0:9c:4d:bf:aa:5b:02:76:ce:b3:a3:2e:9c:e5
    <86>Sep  3 10:30:18 hdfs-master-0 sshd[23587]: pam_unix(sshd:session): session opened for user ubuntu by (uid=0)

    ----------> THIS IS THE LINE WE WANT TO SEE <--------
    <13>Sep  3 10:30:18 hdfs-master-0 [Flume](http://flume.apache.org/)Demo: Can you see me now Thu Sep 3 12:30:15 CEST 2015 ??
    ----------> THIS IS THE LINE WE WANTED TO SEE <-----------

    <38>Sep  3 10:30:19 hdfs-master-0 sshd[23640]: Received disconnect from 172.31.20.146: 11: disconnected by user
    <86>Sep  3 10:30:19 hdfs-master-0 sshd[23587]: pam_unix(sshd:session): session closed for user ubuntu
    <35>Sep  3 10:30:26 hdfs-master-0 sshd[23642]: error: Could not load host key: /etc/ssh/ssh_host_ed25519_key
    <38>Sep  3 10:30:26 hdfs-master-0 sshd[23642]: Accepted publickey for ubuntu from 172.31.20.146 port 55589 ssh2: RSA 52:90:a0:9c:4d:bf:aa:5b:02:76:ce:b3:a3:2e:9c:e5
    <86>Sep  3 10:30:26 hdfs-master-0 sshd[23642]: pam_unix(sshd:session): session opened for user ubuntu by (uid=0)
    <13>Sep  3 10:30:27 hdfs-master-0 [Flume](http://flume.apache.org/)Demo: Can you see me now Thu Sep 3 12:30:23 CEST 2015 ??
    Connection to 172.31.39.181 closed.

## Reset

    :~$ ./bin/50-reset.sh 
    [Thu Sep 3 12:47:34 CEST 2015] [demo] [local0.debug] : Successfully switched to flume
    [Thu Sep 3 12:48:44 CEST 2015] [demo] [local0.debug] : Successfully reset flume
    [Thu Sep 3 12:48:49 CEST 2015] [demo] [local0.debug] : Successfully deployed juju-gui to machine-0
    [Thu Sep 3 12:48:50 CEST 2015] [demo] [local0.info] : Juju GUI now available on https://X.X.X.X with user admin:password


# Known Issues
## Syslog Reading

For some reason, [Flume](http://flume.apache.org/) is currently writing very small files to disk instead of big chunks. You may have to run the cat or tail on several files to get it to work. 
