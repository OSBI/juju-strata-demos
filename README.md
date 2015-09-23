#####################################################################
#
# Demo Name: Datafari Enterprise Search Engine
#
#####################################################################

Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 

# Purpose of the demo

[Datafari](http://www.datafari.com/en/) is the most advanced open source enterprise search solution!

[Datafari](http://www.datafari.com/en/) leverages several Apache building blocks, and integrates them to make your life easier. Modular, reliable and documented, [Datafari](http://www.datafari.com/en/) can be used as a content management solution, but it can also be used as a product for a third party solution.

* Apache [Solr](http://lucene.apache.org/solr/) 4: A scalability for up to hundreds of millions of documents, advanced functionnalities (facets, autocompletion, suggestions...)
* Apache [Manifold](https://manifoldcf.apache.org/)CF: secured connectors for the main data sources.
* AjaxFranceLabs: a graphical framework in HTML5/Javascript

# Main Services deployed
## [Datafari](http://www.datafari.com/en/)

[Datafari](http://www.datafari.com/en/) is a charm developed by France Labs, a member of our Charm Partner Programme. It is not yet published to the charm store, but this is a roadmapped evolution. More information on [their website](http://www.datafari.com/en/)

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
## Juju GUI 

The GUI for this demo should look like 

![](https://github.com/SaMnCo/juju-strata-demos/blob/datafari/var/screenshots/juju-gui-001.png)


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

[Hadoop](https://hadoop.apache.org/) uses a directory tree structure stored in HDFS. In this specific cas we only use it as a data store, hence there are not much computations that we can need

Let's list what's inside our tree structure using the HDFS command line:

    $ hdfs dfs -ls -R /
    drwxr-xr-x   - ubuntu supergroup          0 2015-09-23 06:10 /dataset
    -rw-r--r--   1 ubuntu supergroup      26624 2015-09-23 06:10 /dataset/EEMC-EPMIsla.doc
    -rw-r--r--   1 ubuntu supergroup      44032 2015-09-23 06:10 /dataset/EEMCLabelMid-8.01.doc
    -rw-r--r--   1 ubuntu supergroup      26624 2015-09-23 06:10 /dataset/EEO.doc
    -rw-r--r--   1 ubuntu supergroup     306688 2015-09-23 06:10 /dataset/EES Board 3Q r10 Blue steffes.ppt
    -rw-r--r--   1 ubuntu supergroup      74752 2015-09-23 06:10 /dataset/EITF 97-10.doc
    -rw-r--r--   1 ubuntu supergroup      60950 2015-09-23 06:10 /dataset/EIX092600.pdf
    -rw-r--r--   1 ubuntu supergroup     399872 2015-09-23 06:10 /dataset/EKflyer2001.doc
    -rw-r--r--   1 ubuntu supergroup     142336 2015-09-23 06:10 /dataset/ENA Upstream ( Master).doc
    -rw-r--r--   1 ubuntu supergroup      28672 2015-09-23 06:10 /dataset/ENRON CORP Guaranty (Reliant).doc
    -rw-r--r--   1 ubuntu supergroup      20992 2015-09-23 06:10 /dataset/EOL adds HoustonStreet.doc
    -rw-r--r--   1 ubuntu supergroup      19456 2015-09-23 06:10 /dataset/EOL adds.doc
    -rw-r--r--   1 ubuntu supergroup     382210 2015-09-23 06:10 /dataset/EOL_A4_Intl Sea Freight.pdf
    -rw-r--r--   1 ubuntu supergroup      37888 2015-09-23 06:10 /dataset/EPNG Capacity Proposal II.doc
    -rw-r--r--   1 ubuntu supergroup      35840 2015-09-23 06:10 /dataset/EPNG Capacity Proposal II1.doc
    -rw-r--r--   1 ubuntu supergroup      57856 2015-09-23 06:10 /dataset/EPower Implementation Plan.doc
    -rw-r--r--   1 ubuntu supergroup     348160 2015-09-23 06:10 /dataset/ERCOT Transmission Treia.ppt
    -rw-r--r--   1 ubuntu supergroup      23040 2015-09-23 06:10 /dataset/ERCOT UBU Seller's Choice amend 5-21-01.doc

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

