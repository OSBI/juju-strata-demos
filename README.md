#####################################################################
#
# Demo Name: [Hadoop](https://hadoop.apache.org/) & [Spark](https://spark.apache.org/) Functionnality
#
#####################################################################

Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 

# Purpose of the demo

This demo aims at deploying [Spark](https://spark.apache.org/) on YARN, and test the functionality through various setups and GUIs.

# Main Services deployed
## [Hadoop](https://hadoop.apache.org/) Cluster

In this example the [Hadoop](https://hadoop.apache.org/) Cluster is production ready. It has 2 HDFS namenodes (master & secondary), 3 compute slaves and a YARN Master. 

It can scale out by adding more compute-slave units.

## [Spark](https://spark.apache.org/) 

[Spark](https://spark.apache.org/) is deployed and connected to YARN to scale to all HDFS nodes. 

## GUIs
### [Zeppelin](https://zeppelin.incubator.apache.org/)

[Zeppelin](https://zeppelin.incubator.apache.org/) (from NFLabs) is deployed on the [Spark](https://spark.apache.org/) unit, and provides an interface to publish [Spark](https://spark.apache.org/) Apps into [Spark](https://spark.apache.org/) in real time. 

### [iPython Notebook](http://ipython.org/notebook.html)

[iPython Notebook](http://ipython.org/notebook.html) is deployed on the [Spark](https://spark.apache.org/) unit, and also provides an interface to publish [Spark](https://spark.apache.org/) Apps into [Spark](https://spark.apache.org/) in real time. 


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

	./bin/01-deploy-apache-[Spark](https://spark.apache.org/).sh

Will deploy the charms required for the demo

## Demos  

All the scripts starting in "1X-XXXXXXX.sh" are demo scripts you can run

### [Spark](https://spark.apache.org/) Pi demo

	./bin/10-run-sparkpi.sh

This will run a [Spark](https://spark.apache.org/) Application that computes Pi to a given decimal. 

    $ ./bin/10-run-sparkpi.sh 
    [Wed Sep 2 18:21:12 CEST 2015] [demo] [local0.debug] : Successfully switched to canonical
    Warning: Permanently added 'X.X.X.X' (ECDSA) to the list of known hosts.
    Warning: Permanently added 'Y.Y.Y.Y' (ECDSA) to the list of known hosts.
    Spark assembly has been built with Hive, including Datanucleus jars on classpath
    Pi is roughly 3.141056                                                                                                                                       
    Connection to Y.Y.Y.Y closed.


### [Zeppelin](https://zeppelin.incubator.apache.org/) demo

    ./bin/11-run-zeppelin.sh

This will give you the URL to connect to to start using [Zeppelin](https://zeppelin.incubator.apache.org/)

    $ ./bin/11-run-zeppelin.sh 
    [Wed Sep 2 18:22:53 CEST 2015] [demo] [local0.debug] : Successfully switched to canonical
    [Wed Sep 2 18:22:54 CEST 2015] [demo] [local0.info] : Point your browser at http://X.X.X.X:9090


### Notebook demo

    ./bin/12-run-notebook.sh

This will give you the URL to connect to to start using [iPython Notebook](http://ipython.org/notebook.html)

    $ ./bin/12-run-notebook.sh 
    [Wed Sep 2 18:23:25 CEST 2015] [demo] [local0.debug] : Successfully switched to canonical
    [Wed Sep 2 18:23:26 CEST 2015] [demo] [local0.info] : Point your browser at http://X.X.X.X:8880

### HDFS demo

    ./bin/13-run-hdfs.sh

This is a simple demo that shows we can manipulate HDFS via CLI

    $ ./bin/13-run-hdfs.sh 
    [Wed Sep 2 18:24:59 CEST 2015] [demo] [local0.debug] : Successfully switched to canonical
    Warning: Permanently added 'X.X.X.X' (ECDSA) to the list of known hosts.
    Warning: Permanently added 'X.X.X.X' (ECDSA) to the list of known hosts.
    Found 3 items
    drwxr-xr-x   - hdfs   supergroup          0 2015-09-02 16:05 /tmp/[Hadoop](https://hadoop.apache.org/)
    drwxrwxrwt   - hdfs   supergroup          0 2015-09-02 16:05 /tmp/[Hadoop](https://hadoop.apache.org/)-yarn
    drwxrwxrwx   - ubuntu supergroup          0 2015-09-02 16:25 /tmp/hdfs-test
    15/09/02 16:25:15 INFO fs.TrashPolicyDefault: Namenode trash configuration: Deletion interval = 0 minutes, Emptier interval = 0 minutes.
    Deleted /tmp/hdfs-test
    Found 2 items
    drwxr-xr-x   - hdfs supergroup          0 2015-09-02 16:05 /tmp/[Hadoop](https://hadoop.apache.org/)
    drwxrwxrwt   - hdfs supergroup          0 2015-09-02 16:05 /tmp/[Hadoop](https://hadoop.apache.org/)-yarn
    Connection to X.X.X.X closed.


### Terasort demo

    ./bin/14-run-terasort.sh

This runs terasort on our bundle.

    $ ./bin/14-run-terasort.sh 
    [Wed Sep 2 18:28:55 CEST 2015] [demo] [local0.debug] : Successfully switched to canonical
    15/09/02 16:29:05 INFO client.RMProxy: Connecting to ResourceManager at yarn-master-0/X.X.X.X:8032
    15/09/02 16:29:06 INFO terasort.TeraSort: Generating 1000000 using 3
    15/09/02 16:29:06 INFO mapreduce.JobSubmitter: number of splits:3
    15/09/02 16:29:06 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1441210010493_0002
    15/09/02 16:29:06 INFO impl.YarnClientImpl: Submitted application application_1441210010493_0002
    15/09/02 16:29:06 INFO mapreduce.Job: The url to track the job: http://yarn-master-0:8088/proxy/application_1441210010493_0002/
    15/09/02 16:29:06 INFO mapreduce.Job: Running job: job_1441210010493_0002
    15/09/02 16:29:13 INFO mapreduce.Job: Job job_1441210010493_0002 running in uber mode : false
    15/09/02 16:29:13 INFO mapreduce.Job:  map 0% reduce 0%
    15/09/02 16:29:20 INFO mapreduce.Job:  map 100% reduce 0%
    15/09/02 16:29:21 INFO mapreduce.Job: Job job_1441210010493_0002 completed successfully
    15/09/02 16:29:21 INFO mapreduce.Job: Counters: 31
        File System Counters
            FILE: Number of bytes read=0
            FILE: Number of bytes written=279855
            FILE: Number of read operations=0
            FILE: Number of large read operations=0
            FILE: Number of write operations=0
            HDFS: Number of bytes read=252
            HDFS: Number of bytes written=100000000
            HDFS: Number of read operations=12
            HDFS: Number of large read operations=0
            HDFS: Number of write operations=6
        Job Counters 
            Launched map tasks=3
            Other local map tasks=3
            Total time spent by all maps in occupied slots (ms)=15497
            Total time spent by all reduces in occupied slots (ms)=0
            Total time spent by all map tasks (ms)=15497
            Total vcore-seconds taken by all map tasks=15497
            Total megabyte-seconds taken by all map tasks=15868928
        Map-Reduce Framework
            Map input records=1000000
            Map output records=1000000
            Input split bytes=252
            Spilled Records=0
            Failed Shuffles=0
            Merged Map outputs=0
            GC time elapsed (ms)=223
            CPU time spent (ms)=6520
            Physical memory (bytes) snapshot=557150208
            Virtual memory (bytes) snapshot=2500542464
            Total committed heap usage (bytes)=297271296
        org.apache.[Hadoop](https://hadoop.apache.org/).examples.terasort.TeraGen$Counters
            CHECKSUM=2148987642402270
        File Input Format Counters 
            Bytes Read=0
        File Output Format Counters 
            Bytes Written=100000000
    15/09/02 16:29:42 INFO terasort.TeraSort: starting
    15/09/02 16:29:43 INFO input.FileInputFormat: Total input paths to process : 3
    Spent 124ms computing base-splits.
    Spent 2ms computing TeraScheduler splits.
    Computing input splits took 128ms
    Sampling 3 splits of 3
    Making 3 from 99999 sampled records
    Computing parititions took 761ms
    Spent 902ms computing partitions.
    15/09/02 16:29:44 INFO client.RMProxy: Connecting to ResourceManager at yarn-master-0/172.31.16.103:8032
    15/09/02 16:29:44 INFO mapreduce.JobSubmitter: number of splits:3
    15/09/02 16:29:45 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1441210010493_0003
    15/09/02 16:29:45 INFO impl.YarnClientImpl: Submitted application application_1441210010493_0003
    15/09/02 16:29:45 INFO mapreduce.Job: The url to track the job: http://yarn-master-0:8088/proxy/application_1441210010493_0003/
    15/09/02 16:29:45 INFO mapreduce.Job: Running job: job_1441210010493_0003
    15/09/02 16:29:51 INFO mapreduce.Job: Job job_1441210010493_0003 running in uber mode : false
    15/09/02 16:29:51 INFO mapreduce.Job:  map 0% reduce 0%
    15/09/02 16:29:59 INFO mapreduce.Job:  map 100% reduce 0%
    15/09/02 16:30:07 INFO mapreduce.Job:  map 100% reduce 100%
    15/09/02 16:30:07 INFO mapreduce.Job: Job job_1441210010493_0003 completed successfully
    15/09/02 16:30:08 INFO mapreduce.Job: Counters: 50
        File System Counters
            FILE: Number of bytes read=43312639
            FILE: Number of bytes written=87217341
            FILE: Number of read operations=0
            FILE: Number of large read operations=0
            FILE: Number of write operations=0
            HDFS: Number of bytes read=100000384
            HDFS: Number of bytes written=100000000
            HDFS: Number of read operations=18
            HDFS: Number of large read operations=0
            HDFS: Number of write operations=6
        Job Counters 
            Launched map tasks=3
            Launched reduce tasks=3
            Data-local map tasks=2
            Rack-local map tasks=1
            Total time spent by all maps in occupied slots (ms)=16301
            Total time spent by all reduces in occupied slots (ms)=17815
            Total time spent by all map tasks (ms)=16301
            Total time spent by all reduce tasks (ms)=17815
            Total vcore-seconds taken by all map tasks=16301
            Total vcore-seconds taken by all reduce tasks=17815
            Total megabyte-seconds taken by all map tasks=16692224
            Total megabyte-seconds taken by all reduce tasks=18242560
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
            GC time elapsed (ms)=813
            CPU time spent (ms)=19830
            Physical memory (bytes) snapshot=1516605440
            Virtual memory (bytes) snapshot=5014552576
            Total committed heap usage (bytes)=974651392
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
    15/09/02 16:30:08 INFO terasort.TeraSort: done


## Resetting 

	./bin/50-reset.sh

Will reset the environment but keep it alive

## Clean

	./bin/99-cleanup.sh

Will completely rip of the environment and delete local files

# Sample Outputs
## Bootstrapping

    :~$ ./bin/00-bootstrap.sh 
    [Wed Sep 2 17:52:36 CEST 2015] [demo] [local0.debug] : Validating dependencies
    [Wed Sep 2 17:52:37 CEST 2015] [demo] [local0.debug] : Successfully switched to canonical
    [Wed Sep 2 17:56:53 CEST 2015] [demo] [local0.debug] : Succesfully bootstrapped canonical
    [Wed Sep 2 17:57:04 CEST 2015] [demo] [local0.debug] : Successfully deployed juju-gui to machine-0
    [Wed Sep 2 17:57:06 CEST 2015] [demo] [local0.info] : Juju GUI now available on https://52.18.73.57 with user admin:869ab5e5049321d54a8fca0f27d6cdf0
    [Wed Sep 2 17:57:18 CEST 2015] [demo] [local0.debug] : Bootstrapping process finished for canonical. You can safely move to deployment.



## Deployment

    :~$ ./bin/01-deploy-apache-[Spark](https://spark.apache.org/).sh 
    [Wed Sep 2 18:00:04 CEST 2015] [demo] [local0.debug] : Successfully switched to canonical
    [Wed Sep 2 18:00:16 CEST 2015] [demo] [local0.debug] : Successfully deployed hdfs-master
    [Wed Sep 2 18:00:19 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=7G cpu-cores=2 root-disk=32G" for hdfs-master
    [Wed Sep 2 18:00:33 CEST 2015] [demo] [local0.debug] : Successfully deployed secondary-namenode
    [Wed Sep 2 18:00:36 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=7G cpu-cores=2 root-disk=32G" for secondary-namenode
    [Wed Sep 2 18:00:37 CEST 2015] [demo] [local0.debug] : Successfully created relation between hdfs-master and secondary-namenode
    [Wed Sep 2 18:00:50 CEST 2015] [demo] [local0.debug] : Successfully deployed yarn-master
    [Wed Sep 2 18:00:53 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=7G cpu-cores=2" for yarn-master
    [Wed Sep 2 18:01:07 CEST 2015] [demo] [local0.debug] : Successfully deployed compute-slave
    [Wed Sep 2 18:01:10 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=3G cpu-cores=2 root-disk=32G" for compute-slave
    [Wed Sep 2 18:01:24 CEST 2015] [demo] [local0.debug] : Successfully added 2 units of compute-slave
    [Wed Sep 2 18:01:29 CEST 2015] [demo] [local0.debug] : Successfully deployed plugin
    [Wed Sep 2 18:01:30 CEST 2015] [demo] [local0.debug] : Successfully created relation between yarn-master and hdfs-master
    [Wed Sep 2 18:01:32 CEST 2015] [demo] [local0.debug] : Successfully created relation between compute-slave and yarn-master
    [Wed Sep 2 18:01:33 CEST 2015] [demo] [local0.debug] : Successfully created relation between compute-slave and hdfs-master
    [Wed Sep 2 18:01:36 CEST 2015] [demo] [local0.debug] : Successfully created relation between plugin and yarn-master
    [Wed Sep 2 18:01:37 CEST 2015] [demo] [local0.debug] : Successfully created relation between plugin and hdfs-master
    [Wed Sep 2 18:01:48 CEST 2015] [demo] [local0.debug] : Successfully deployed [Spark](https://spark.apache.org/)
    [Wed Sep 2 18:01:51 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=3G cpu-cores=2" for [Spark](https://spark.apache.org/)
    [Wed Sep 2 18:01:52 CEST 2015] [demo] [local0.debug] : Successfully created relation between [Spark](https://spark.apache.org/) and plugin
    [Wed Sep 2 18:01:57 CEST 2015] [demo] [local0.debug] : Successfully deployed [Zeppelin](https://zeppelin.incubator.apache.org/)
    [Wed Sep 2 18:01:58 CEST 2015] [demo] [local0.debug] : Successfully created relation between between [Spark](https://spark.apache.org/) and [Zeppelin](https://zeppelin.incubator.apache.org/)
    [Wed Sep 2 18:01:59 CEST 2015] [demo] [local0.debug] : Successfully exposed [Zeppelin](https://zeppelin.incubator.apache.org/)
    [Wed Sep 2 18:02:02 CEST 2015] [demo] [local0.debug] : Successfully deployed notebook
    [Wed Sep 2 18:02:03 CEST 2015] [demo] [local0.debug] : Successfully created relation between between [Spark](https://spark.apache.org/) and notebook
    [Wed Sep 2 18:02:04 CEST 2015] [demo] [local0.debug] : Successfully exposed notebook

## Reset

    :~$ ./bin/50-reset.sh 
