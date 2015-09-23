#####################################################################
#
# Demo Name: Datafari Enterprise Search Engine
#
#####################################################################

Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 

# Purpose of the demo

[Datafari](http://www.datafari.com/en/) is the most advanced open source enterprise search solution!

[Datafari](http://www.datafari.com/en/) leverages several Apache building blocks, and integrates them to make your life easier. Modular, reliable and documented, [Datafari](http://www.datafari.com/en/) can be used as a content management solution, but it can also be used as a product for a third party solution.

* Apache Solr 4: A scalability for up to hundreds of millions of documents, advanced functionnalities (facets, autocompletion, suggestions...)
* Apache [Manifold](https://manifoldcf.apache.org/)CF: secured connectors for the main data sources.
* AjaxFranceLabs: a graphical framework in HTML5/Javascript

# Main Services deployed
## [Datafari](http://www.datafari.com/en/)

[Datafari](http://www.datafari.com/en/) is a charm developed by France Labs, a member of our Charm Partner Programme. It is not yet published to the charm store, but this is a roadmapped evolution. More information on [their website](http://www.[Datafari](http://www.datafari.com/en/).com)

## [Hadoop](https://hadoop.apache.org/) Cluster

We run a simple [Hadoop](https://hadoop.apache.org/) cluster with an HDFS Master + and 3 datanodes. 


# Data Sources

We use a set of ~20MB of documents that is ingested in [Hadoop](https://hadoop.apache.org/). Note that the indexing process is a batch job and takes time. This demo cannot fully run "in real time" and needs to be pre-deployed. 

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

	./bin/01-deploy-[Datafari](http://www.datafari.com/en/).sh

Will deploy the charms required for the demo

## Configure  

	./bin/10-setup-datafari.sh

Will install documents into [Hadoop](https://hadoop.apache.org/) for indexing then start the crawler using a juju action. 

## Resetting 

	./bin/50-reset.sh

Will reset the environment but keep it alive.

## Clean

	./bin/99-cleanup.sh

Will completely rip of the environment and delete local files

# Validation Check and GUIs
## [Datafari](http://www.datafari.com/en/) GUI Access

Once deployed, you can connect on the [Datafari](http://www.datafari.com/en/) unit on port 8080 (by default) 

You can get the IP address of the unit via 

    juju status [Datafari](http://www.datafari.com/en/)/0 --format tabular| grep [Datafari](http://www.datafari.com/en/) | awk '{ print $7 }' | tail -n1

Then 

* URL of the search GUI is : http://IP_ADDRESS:8080/[Datafari](http://www.datafari.com/en/)
* URL of the Admin GUI is : http://IP_ADDRESS:8080/[Datafari](http://www.datafari.com/en/)/admin

Default credentials are admin:admin

## Using the Search Engine

The search page should look like

![](https://github.com/SaMnCo/juju-strata-demos/blob/datafari/var/screenshots/datafari-gui-001.png)

Then you can type and search things. Our demo dataset is made of about 200 documents extracted from the ENRONgate so you can use words from the energy vocabulary for example. 
Words that will give results: edison, international, enron, energy... 

The results you get are a list of links to the documents like 

![](https://github.com/SaMnCo/juju-strata-demos/blob/datafari/var/screenshots/datafari-gui-002.png)

**IMPORTANT NOTE**: THe links are clickable but **will return an error** because this charm doesn't yet provide URL forwarding for HDFS links. Therefore do not click the links. 

**Key Take Away**: [Datafari](http://www.datafari.com/en/) allows any enterprise to build their enterprise search engine, for all documents stored in [Hadoop](https://hadoop.apache.org/) or other datastores, including emails, dropbox and others. 

## Using the Admin Page

The search page should look like

![](https://github.com/SaMnCo/juju-strata-demos/blob/datafari/var/screenshots/datafari-admin-gui-001.png)

### Statistics

When you click on Statistics, you can access the searches that users made in the past, and identify which keywords are most used. This can help adjusting search settings, adding synonyms and other key mechanisms to improve user experience

![](https://github.com/SaMnCo/juju-strata-demos/blob/datafari/var/screenshots/datafari-admin-gui-002.png)

![](https://github.com/SaMnCo/juju-strata-demos/blob/datafari/var/screenshots/datafari-admin-gui-003.png)

### [Manifold](https://manifoldcf.apache.org/) Configuration

[Manifold](https://manifoldcf.apache.org/) is the Apache project for search that powers [Datafari](http://www.datafari.com/en/). You can access it by hitting "Search Engine Configuration" in the left hand toolbar. 

When connected with default credentials (admin:admin), you can then have a look at the repository connections (list of search targets). 

![](https://github.com/SaMnCo/juju-strata-demos/blob/datafari/var/screenshots/datafari-admin-gui-005.png)

In this demo we focus on [Hadoop](https://hadoop.apache.org/), but many search targets can be added, including popular engines such as Dropbox: 

![](https://github.com/SaMnCo/juju-strata-demos/blob/datafari/var/screenshots/datafari-admin-gui-004.png)
 
## Using [Hadoop](https://hadoop.apache.org/)

[Hadoop](https://hadoop.apache.org/) uses a directory tree structure stored in HDFS.

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
    [Wed Sep 9 09:04:23 CEST 2015] [demo] [local0.debug] : Successfully switched to [Datafari](http://www.datafari.com/en/)
    [Wed Sep 9 09:09:19 CEST 2015] [demo] [local0.debug] : Succesfully bootstrapped [Datafari](http://www.datafari.com/en/)
    [Wed Sep 9 09:09:31 CEST 2015] [demo] [local0.debug] : Successfully deployed juju-gui to machine-0
    [Wed Sep 9 09:09:32 CEST 2015] [demo] [local0.info] : Juju GUI now available on https://X.X.X.X with user admin:
    [Wed Sep 9 09:09:48 CEST 2015] [demo] [local0.debug] : Bootstrapping process finished for [Datafari](http://www.datafari.com/en/). You can safely move to deployment.

## Deployment

    :~$ ./bin/01-deploy-[Datafari](http://www.datafari.com/en/).sh 
    [Wed Sep 9 09:37:11 CEST 2015] [demo] [local0.debug] : Successfully switched to [Datafari](http://www.datafari.com/en/)
    [Wed Sep 9 09:38:25 CEST 2015] [demo] [local0.debug] : Successfully deployed [Hadoop](https://hadoop.apache.org/)-master
    [Wed Sep 9 09:38:28 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=4 root-disk=32G" for [Hadoop](https://hadoop.apache.org/)-master
    [Wed Sep 9 09:38:40 CEST 2015] [demo] [local0.debug] : Successfully deployed [Hadoop](https://hadoop.apache.org/)-slavecluster
    [Wed Sep 9 09:38:43 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=4 root-disk=32G" for [Hadoop](https://hadoop.apache.org/)-slavecluster
    [Wed Sep 9 09:38:57 CEST 2015] [demo] [local0.debug] : Successfully added 2 units of [Hadoop](https://hadoop.apache.org/)-slavecluster
    [Wed Sep 9 09:38:58 CEST 2015] [demo] [local0.debug] : Successfully created relation between [Hadoop](https://hadoop.apache.org/)-master:namenode and [Hadoop](https://hadoop.apache.org/)-slavecluster:datanode
    [Wed Sep 9 09:38:59 CEST 2015] [demo] [local0.debug] : Successfully created relation between [Hadoop](https://hadoop.apache.org/)-master:resourcemanager and [Hadoop](https://hadoop.apache.org/)-slavecluster:nodemanager

## Reset

    :~$ ./bin/50-reset.sh 
    [Wed Sep 9 09:38:59 CEST 2015] [demo] [local0.debug] : Successfully switched to [Datafari](http://www.datafari.com/en/)
    [Wed Sep 9 09:38:59 CEST 2015] [demo] [local0.debug] : Successfully reset [Datafari](http://www.datafari.com/en/)

