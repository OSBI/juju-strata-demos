#####################################################################
#
# Demo Name: Analytics Demo - SpagoBI with Many Data Sources
#
#
#####################################################################

Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 

# Purpose of the demo


Datafari is the most advanced open source enterprise search solution!

Datafari leverages several Apache building blocks, and integrates them to make your life easier. Modular, reliable and documented, Datafari can be used as a content management solution, but it can also be used as a product for a third party solution.

* Apache Solr 4: A scalability for up to hundreds of millions of documents, advanced functionnalities (facets, autocompletion, suggestions...)
* Apache ManifoldCF: secured connectors for the main data sources.
* AjaxFranceLabs: a graphical framework in HTML5/Javascript

# Main Services deployed
## Datafari

Datafari is a charm developed by France Labs, a member of our Charm Partner Programme. It is not yet published to the charm store, but this is a roadmapped evolution. More information on [their website](http://www.datafari.com)

## Hadoop Cluster

We run a simple Hadoop cluster with an HDFS Master + and 3 datanodes. 


# Data Sources

We use a set of ~20MB of documents that is ingested in Hadoop. Note that the indexing process is a batch job and takes time. This demo cannot fully run "in real time" and needs to be pre-deployed. 

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

	./bin/01-deploy-datafari.sh

Will deploy the charms required for the demo

## Configure  

	./bin/10-setup.sh

Will install documents into Hadoop for indexing. 

## Resetting 

	./bin/50-reset.sh

Will reset the environment but keep it alive.

## Clean

	./bin/99-cleanup.sh

Will completely rip of the environment and delete local files

# Validation Check and GUIs
## Datafari GUI Access

Once deployed, you can connect on the Datafari unit on port 80 (by default) 

The default credentials are: 

## Using Hadoop

Hadoop uses a directory tree structure stored in HDFS.


Let's list what's inside our tree structure using the HDFS command line:

    $ hdfs dfs -ls -R /user/ubuntu
    drwxr-xr-x   - ubuntu supergroup          0 2015-09-08 10:19 /user/ubuntu/inventory_fact_1998
    -rw-r--r--   3 ubuntu supergroup     330223 2015-09-08 10:19 /user/ubuntu/inventory_fact_1998/inventory_fact_1998.csv
    drwxr-xr-x   - ubuntu supergroup          0 2015-09-08 10:20 /user/ubuntu/product
    -rw-r--r--   3 ubuntu supergroup     153791 2015-09-08 10:20 /user/ubuntu/product/product.csv
    drwxr-xr-x   - ubuntu supergroup          0 2015-09-08 10:19 /user/ubuntu/product_class
    -rw-r--r--   3 ubuntu supergroup       5043 2015-09-08 10:19 /user/ubuntu/product_class/product_class.csv
    drwxr-xr-x   - ubuntu supergroup          0 2015-09-08 10:19 /user/ubuntu/time_by_day
    -rw-r--r--   3 ubuntu supergroup      43940 2015-09-08 10:19 /user/ubuntu/time_by_day/time_by_day.csv
    drwxr-xr-x   - ubuntu supergroup          0 2015-09-08 08:25 /user/ubuntu/warehouse

And we can read inside one file with 

    ubuntu@plugin-2:/home/ubuntu$ hdfs dfs -cat /user/ubuntu/product_class/product_class.csv
    1,Nuts,Specialty,Produce,Food
    2,Shellfish,Seafood,Seafood,Food
    3,Canned Fruit,Fruit,Canned Products,Food
    4,Spices,Baking Goods,Baking Goods,Food
    5,Pasta,Starchy Foods,Starchy Foods,Food
    6,Yogurt,Dairy,Dairy,Food
    7,Coffee,Dry Goods,Baking Goods,Drink
    8,Deli Meats,Meat,Deli,Food
    9,Ice Cream,Frozen Desserts,Frozen Foods,Food

# Sample Outputs
## Bootstrapping

    :~$ ./bin/00-bootstrap.sh 
    [Wed Sep 9 09:04:22 CEST 2015] [demo] [local0.debug] : Validating dependencies
    [Wed Sep 9 09:04:23 CEST 2015] [demo] [local0.debug] : Successfully switched to datafari
    [Wed Sep 9 09:09:19 CEST 2015] [demo] [local0.debug] : Succesfully bootstrapped datafari
    [Wed Sep 9 09:09:31 CEST 2015] [demo] [local0.debug] : Successfully deployed juju-gui to machine-0
    [Wed Sep 9 09:09:32 CEST 2015] [demo] [local0.info] : Juju GUI now available on https://52.19.109.218 with user admin:3f793dd629b195e1edaef8a07557ed5f
    [Wed Sep 9 09:09:48 CEST 2015] [demo] [local0.debug] : Bootstrapping process finished for datafari. You can safely move to deployment.

## Deployment

    :~$ ./bin/01-deploy-datafari.sh 
    [Wed Sep 9 09:37:11 CEST 2015] [demo] [local0.debug] : Successfully switched to datafari
    [Wed Sep 9 09:38:25 CEST 2015] [demo] [local0.debug] : Successfully deployed hadoop-master
    [Wed Sep 9 09:38:28 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=4 root-disk=32G" for hadoop-master
    [Wed Sep 9 09:38:40 CEST 2015] [demo] [local0.debug] : Successfully deployed hadoop-slavecluster
    [Wed Sep 9 09:38:43 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=4 root-disk=32G" for hadoop-slavecluster
    [Wed Sep 9 09:38:57 CEST 2015] [demo] [local0.debug] : Successfully added 2 units of hadoop-slavecluster
    [Wed Sep 9 09:38:58 CEST 2015] [demo] [local0.debug] : Successfully created relation between hadoop-master:namenode and hadoop-slavecluster:datanode
    [Wed Sep 9 09:38:59 CEST 2015] [demo] [local0.debug] : Successfully created relation between hadoop-master:resourcemanager and hadoop-slavecluster:nodemanager

## Reset

    :~$ ./bin/50-reset.sh 
    [Wed Sep 9 09:38:59 CEST 2015] [demo] [local0.debug] : Successfully switched to datafari
    [Wed Sep 9 09:38:59 CEST 2015] [demo] [local0.debug] : Successfully reset datafari

