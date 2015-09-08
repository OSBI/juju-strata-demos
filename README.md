#####################################################################
#
# Demo Name: Analytics Demo - SpagoBI with Many Data Sources
#
#
#####################################################################

Maintainer: Samuel Cozannet <samuel.cozannet@canonical.com> 

# Purpose of the demo

This demo aims at deploying SpagoBI and connect it to many different data sources, to express how easy it is to deploy a very complex data analytics solution with Juju. 


# Main Services deployed
## spagoBI

SpagoBI is the main attraction of this demo, and the center of gravity of all data sources. To deploy it, we install a small MySQL server, a powerful Tomcat server, and the spagoBI subordinate charm, then we connect them together. 

## Hadoop Cluster

We run a simple Hadoop cluster with YARN, made of an HDFS Master + Compute Slaves, to which we attach a YARN Master to orchestrate compute. 

## HBase

On top of our Hadoop Cluster we run a HBase cluster, with a Master, a Region Server, orchestrated by a ZooKeeper cluster. 

## Spark 

We run a set of Spark nodes managed via YARN on top of our Hadoop Cluster.

## Hive

We have a small instance of Hive, running with MySQL. 

## Cassandra

We run a small cluster of Cassandra (3 nodes), the main tabular noSQL datastore on the market.

## MongoDB

We run a small cluster of MongoDB (only 1 node for this demo), the main noSQL document datastore available. 

## MySQL

noSQL is not everything, so we also have a data source in a MySQL node.

## PostgreSQL

To even things between SQL stores we also store some data in PostgreSQL.

# Secondary Services deployed 
## ZooKeeper

ZK is a service to manage clusters of other services. In our case, the HBase cluster. We deploy 3 nodes of ZK to simulate a production cluster. 

# Data Sources

TBD (Engineering to provide sources)

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

	./bin/01-deploy-spagobi.sh

Will deploy the charms required for the demo

## Configure  

	./bin/10-setup.sh

Will install datasources into each database and run actions to install them into SpagoBI. 

## Resetting 

	./bin/50-reset.sh

Will reset the environment but keep it alive

## Clean

	./bin/99-cleanup.sh

Will completely rip of the environment and delete local files

# Validation Check and GUIs
## SpagoBI GUI Access

Once deployed, you can connect on the Tomcat unit on port 8080 (by default) to access the SpagoBI GUI: http://<TOMCAT>/SpagoBI

3 default users are provided by default, with a button to access the UI with them. 

* To access the configuration, use the biadmin; 
* To access visualization as an end-user, user biuser;
* To configure more aspects of BI, use bimanager

## Using MySQL

MySQL servers credentials are stored by Juju in /var/lib/mysql/mysql.passwd. Therefore you can run from your client

    $ juju ssh mysql-data-master/0 sudo cat /var/lib/mysql/mysql.passwd 
    XXXXXXXX-YYYY-XXXX-ZZZZ-UUUUUUUUUUUU

So now you have access to the root password. Connect on the mysql-data-master/0 unit with Juju then run 

    $ mysql -uroot -pXXXXXXXX-YYYY-XXXX-ZZZZ-UUUUUUUUUUUU
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 46
    Server version: 5.5.44-0ubuntu0.14.04.1-log (Ubuntu)

    Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> 

OK so you are in the MySQL shell and you can run a few commands to see what's in there. Let's list databases: 

    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | foodmart_key       |
    | mysql              |
    | performance_schema |
    | spagobi            |
    +--------------------+
    5 rows in set (0.00 sec)

So we can see that we have our dataset foodmart_key. Let use it: 

    mysql> use foodmart_key
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

    Database changed

OK great. We are now using our main dataset. What's inside?

    mysql> show tables;
    +-------------------------+
    | Tables_in_foodmart_key  |
    +-------------------------+
    | currency                |
    | customer                |
    | customersmall           |
    | days                    |
    | department              |
    | employee                |
    | employee_closure        |
    | inventory_fact_1998     |
    | position                |
    | product                 |
    | product_class           |
    | productvendite          |
    | promotion               |
    | promozione              |
    | prova                   |
    | region                  |
    | reserve_employee        |
    | salary                  |
    | sales_fact_1998         |
    | sales_fact_1998_virtual |
    | sales_region            |
    | slot                    |
    | state                   |
    | store                   |
    | store_ragged            |
    | table22                 |
    | time_by_day             |
    | warehouse               |
    | warehouse_class         |
    | wbversion               |
    +-------------------------+
    30 rows in set (0.00 sec)

And of course you can run a classic command:

    mysql> select * from reserve_employee where education_level like 'Partial College%';
    +-------------+-------------------+------------+---------------+-------------+----------------+----------+---------------+---------------------+-----------+----------+--------+---------------+-----------------+----------------+--------+
    | employee_id | full_name         | first_name | last_name     | position_id | position_title | store_id | department_id | birth_date          | hire_date | end_date | salary | supervisor_id | education_level | marital_status | gender |
    +-------------+-------------------+------------+---------------+-------------+----------------+----------+---------------+---------------------+-----------+----------+--------+---------------+-----------------+----------------+--------+
    |        1165 | Barbara Harriman  | Barbara    | Harriman      |        NULL | NULL           |        0 |             0 | 1953-04-10 00:00:00 | NULL      | NULL     | 0.0000 |             0 | Partial College | S              | M      |
    |        1166 | Florence Bowen    | Florence   | Bowen         |        NULL | NULL           |        0 |             0 | 1929-07-21 00:00:00 | NULL      | NULL     | 0.0000 |             0 | Partial College | S              | M      |
    |        1168 | Cecil Stone       | Cecil      | Stone         |        NULL | NULL           |        0 |             0 | 1938-08-22 00:00:00 | NULL      | NULL     | 0.0000 |             0 | Partial College | M              | F      |
    |        1169 | Raymond Lippman   | Raymond    | Lippman       |        NULL | NULL           |        0 |             0 | 1976-06-27 00:00:00 | NULL      | NULL     | 0.0000 |             0 | Partial College | M              | M      |
    |        1173 | Edgar Caudill     | Edgar      | Caudill       |        NULL | NULL           |        0 |             0 | 1948-11-20 00:00:00 | NULL      | NULL     | 0.0000 |             0 | Partial College | M              | M      |
    ....


For more information, refer to the [MySQL documentation](http://dev.mysql.com/doc/refman/5.6/en/)

## MongoDB

By default MongoDB will not protect the access to data. We can therefore just connect on the server mongodb/0 and enter into the shell using the command "mongo":

    $ mongo
    MongoDB shell version: 2.4.9
    connecting to: test
    > 

So we can now list databases available

    > show dbs
    foodmart    0.203125GB
    local   1.078125GB
    test    (empty)

Let's use our foodmart example and list collections inside of it

    > use foodmart
    switched to db foodmart
    > show collections
    inventory_fact_1998
    product
    product_class
    store
    system.indexes
    time_by_day

Now if we look at our source CSV file for product_class we can see that: 

    $ head -n 10 var/mongodb/product_class.csv 
    product_class_id,product_subcategory,product_category,product_department,product_family
    1,Nuts,Specialty,Produce,Food
    2,Shellfish,Seafood,Seafood,Food
    3,Canned Fruit,Fruit,Canned Products,Food
    4,Spices,Baking Goods,Baking Goods,Food
    5,Pasta,Starchy Foods,Starchy Foods,Food
    6,Yogurt,Dairy,Dairy,Food
    7,Coffee,Dry Goods,Baking Goods,Drink
    8,Deli Meats,Meat,Deli,Food
    9,Ice Cream,Frozen Desserts,Frozen Foods,Food

And we can also see that the products reference the product class: 

    $ head -n 10 var/mongodb/product.csv 
    product_class_id,product_id,brand_name,product_name,SKU,SRP,gross_weight,net_weight,recyclable_package,low_fat,units_per_case,cases_per_pallet,shelf_width,shelf_height,shelf_depth
    30,1,Washington,Washington Berry Juice,90748583674,2.8500,8.39,6.39,false,false,30,14,16.9,12.6,7.4
    52,2,2,2,96516502499,0.7400,7.42,2,false,true,18,8,13.4,3.71,22.6
    52,3,Washington,Washington Strawberry Drink,58427771925,0.8300,13.1,11.1,true,true,17,13,14.4,11,7.77
    19,4,Washington,Washington Cream Soda,64412155747,3.6400,10.6,9.6,true,false,26,10,22.9,18.9,7.93
    19,5,Washington,Washington Diet Soda,85561191439,2.1900,6.66,4.65,true,false,7,10,20.7,21.9,19.2
    19,6,Washington,Washington Cola,29804642796,1.1500,15.8,13.8,false,false,14,10,6.42,18.1,21.3
    19,7,Washington,Washington Diet Cola,20191444754,2.6100,18,17,true,false,11,7,15,16.9,21
    30,8,Washington,Washington Orange Juice,89770532250,2.5900,8.97,6.97,true,false,27,7,7.56,11.8,8.92
    30,9,Washington,Washington Cranberry Juice,49395100474,2.4200,7.14,5.13,false,false,34,7,18.5,16.1,14.4

Let's output all documents in the MongoDB database that are ice creams (ID=9): 

    > db.product.find( { product_class_id: 9 })
    { "_id" : ObjectId("55eea5b543fcf8131b4326fa"), "product_class_id" : 9, "product_id" : 103, "brand_name" : "Golden", "product_name" : "Golden Ice Cream", "SKU" : NumberLong("46069397330"), "SRP" : 0.95, "gross_weight" : 9.81, "net_weight" : 8.81, "recyclable_package" : "true", "low_fat" : "false", "units_per_case" : 13, "cases_per_pallet" : 8, "shelf_width" : 6.22, "shelf_height" : 15.8, "shelf_depth" : 11.8 }
    { "_id" : ObjectId("55eea5b543fcf8131b4326fb"), "product_class_id" : 9, "product_id" : 104, "brand_name" : "Golden", "product_name" : "Golden Ice Cream Sandwich", "SKU" : NumberLong("49550614953"), "SRP" : 3.89, "gross_weight" : 12.3, "net_weight" : 10.3, "recyclable_package" : "false", "low_fat" : "true", "units_per_case" : 11, "cases_per_pallet" : 8, "shelf_width" : 9.93, "shelf_height" : 17.4, "shelf_depth" : 17.9 }
    { "_id" : ObjectId("55eea5b543fcf8131b432700"), "product_class_id" : 9, "product_id" : 109, "brand_name" : "Golden", "product_name" : "Golden Popsicles", "SKU" : NumberLong("51792051196"), "SRP" : 3.95, "gross_weight" : 19, "net_weight" : 16, "recyclable_package" : "false", "low_fat" : "false", "units_per_case" : 11, "cases_per_pallet" : 12, "shelf_width" : 6.69, "shelf_height" : 10.4, "shelf_depth" : 7.67 }
    { "_id" : ObjectId("55eea5b543fcf8131b432831"), "product_class_id" : 9, "product_id" : 414, "brand_name" : "Big Time", "product_name" : "Big Time Ice Cream", "SKU" : NumberLong("33460944294"), "SRP" : 2.77, "gross_weight" : 19.9, "net_weight" : 16.8, "recyclable_package" : "true", "low_fat" : "true", "units_per_case" : 3, "cases_per_pallet" : 12, "shelf_width" : 12, "shelf_height" : 19.9, "shelf_depth" : 16.3 }
    { "_id" : ObjectId("55eea5b543fcf8131b432832"), "product_class_id" : 9, "product_id" : 415, "brand_name" : "Big Time", "product_name" : "Big Time Ice Cream Sandwich", "SKU" : NumberLong("80798811316"), "SRP" : 2.91, "gross_weight" : 17.4, "net_weight" : 16.3, "recyclable_package" : "true", "low_fat" : "true", "units_per_case" : 6, "cases_per_pallet" : 10, "shelf_width" : 21.9, "shelf_height" : 18.9, "shelf_depth" : 16.5 }
    { "_id" : ObjectId("55eea5b543fcf8131b432837"), "product_class_id" : 9, "product_id" : 420, "brand_name" : "Big Time", "product_name" : "Big Time Popsicles", "SKU" : NumberLong("41470299363"), "SRP" : 2.27, "gross_weight" : 20.6, "net_weight" : 19.6, "recyclable_package" : "true", "low_fat" : "true", "units_per_case" : 29, "cases_per_pallet" : 12, "shelf_width" : 15, "shelf_height" : 9.4, "shelf_depth" : 9.94 }
    { "_id" : ObjectId("55eea5b543fcf8131b432968"), "product_class_id" : 9, "product_id" : 725, "brand_name" : "Imagine", "product_name" : "Imagine Ice Cream", "SKU" : NumberLong("58714897036"), "SRP" : 1.49, "gross_weight" : 7.33, "net_weight" : 5.32, "recyclable_package" : "false", "low_fat" : "false", "units_per_case" : 4, "cases_per_pallet" : 14, "shelf_width" : 21.9, "shelf_height" : 14.8, "shelf_depth" : 3.48 }
    { "_id" : ObjectId("55eea5b543fcf8131b432969"), "product_class_id" : 9, "product_id" : 726, "brand_name" : "Imagine", "product_name" : "Imagine Ice Cream Sandwich", "SKU" : NumberLong("92958348393"), "SRP" : 3.21, "gross_weight" : 8.47, "net_weight" : 6.47, "recyclable_package" : "false", "low_fat" : "true", "units_per_case" : 5, "cases_per_pallet" : 9, "shelf_width" : 20.1, "shelf_height" : 19.6, "shelf_depth" : 10 }
    { "_id" : ObjectId("55eea5b543fcf8131b43296e"), "product_class_id" : 9, "product_id" : 731, "brand_name" : "Imagine", "product_name" : "Imagine Popsicles", "SKU" : NumberLong("92913083434"), "SRP" : 3.81, "gross_weight" : 13.7, "net_weight" : 10.6, "recyclable_package" : "false", "low_fat" : "false", "units_per_case" : 9, "cases_per_pallet" : 11, "shelf_width" : 9.89, "shelf_height" : 4.82, "shelf_depth" : 20.1 }
    { "_id" : ObjectId("55eea5b543fcf8131b432aa4"), "product_class_id" : 9, "product_id" : 1041, "brand_name" : "PigTail", "product_name" : "PigTail Ice Cream", "SKU" : NumberLong("81180350184"), "SRP" : 0.71, "gross_weight" : 20, "net_weight" : 18, "recyclable_package" : "false", "low_fat" : "true", "units_per_case" : 2, "cases_per_pallet" : 7, "shelf_width" : 11.1, "shelf_height" : 22.7, "shelf_depth" : 4.03 }
    { "_id" : ObjectId("55eea5b543fcf8131b432aa5"), "product_class_id" : 9, "product_id" : 1042, "brand_name" : "PigTail", "product_name" : "PigTail Ice Cream Sandwich", "SKU" : NumberLong("86948269009"), "SRP" : 1.15, "gross_weight" : 16.6, "net_weight" : 14.6, "recyclable_package" : "true", "low_fat" : "false", "units_per_case" : 14, "cases_per_pallet" : 6, "shelf_width" : 17.6, "shelf_height" : 17.2, "shelf_depth" : 16.8 }
    { "_id" : ObjectId("55eea5b543fcf8131b432aaa"), "product_class_id" : 9, "product_id" : 1047, "brand_name" : "PigTail", "product_name" : "PigTail Popsicles", "SKU" : NumberLong("34525341391"), "SRP" : 3.23, "gross_weight" : 10, "net_weight" : 8, "recyclable_package" : "true", "low_fat" : "false", "units_per_case" : 16, "cases_per_pallet" : 13, "shelf_width" : 15.5, "shelf_height" : 13.7, "shelf_depth" : 5.81 }
    { "_id" : ObjectId("55eea5b543fcf8131b432bdb"), "product_class_id" : 9, "product_id" : 1352, "brand_name" : "Carrington", "product_name" : "Carrington Ice Cream", "SKU" : NumberLong("84529367089"), "SRP" : 2.65, "gross_weight" : 17.7, "net_weight" : 14.7, "recyclable_package" : "true", "low_fat" : "true", "units_per_case" : 18, "cases_per_pallet" : 10, "shelf_width" : 16.3, "shelf_height" : 20.4, "shelf_depth" : 22.3 }
    { "_id" : ObjectId("55eea5b543fcf8131b432bdc"), "product_class_id" : 9, "product_id" : 1353, "brand_name" : "Carrington", "product_name" : "Carrington Ice Cream Sandwich", "SKU" : NumberLong("44153935313"), "SRP" : 2.24, "gross_weight" : 13.9, "net_weight" : 12.8, "recyclable_package" : "true", "low_fat" : "false", "units_per_case" : 19, "cases_per_pallet" : 7, "shelf_width" : 17.7, "shelf_height" : 20.4, "shelf_depth" : 22.9 }
    { "_id" : ObjectId("55eea5b543fcf8131b432be1"), "product_class_id" : 9, "product_id" : 1358, "brand_name" : "Carrington", "product_name" : "Carrington Popsicles", "SKU" : NumberLong("40161059498"), "SRP" : 2.1, "gross_weight" : 11.5, "net_weight" : 8.5, "recyclable_package" : "false", "low_fat" : "false", "units_per_case" : 13, "cases_per_pallet" : 8, "shelf_width" : 16.4, "shelf_height" : 7.24, "shelf_depth" : 17.9 }

For more information refer to the [MongoDB documentation](http://docs.mongodb.org/manual/reference/mongo-shell/)

## Using Hive

Hive uses a directory tree structure stored in HDFS and maps a SQL database on top of it. There are no specific rights set up so you just have to connect to the hive/0 node. Then turn yourself into the hive user.

    ubuntu@plugin-2:~$ sudo su hive
    hive@plugin-2:/home/ubuntu$ 

Now let's list what's inside our tree structure using the HDFS command line:

    $ hdfs dfs -ls -R /user/hive
    drwxr-xr-x   - hive supergroup          0 2015-09-08 10:19 /user/hive/inventory_fact_1998
    -rw-r--r--   3 hive supergroup     330223 2015-09-08 10:19 /user/hive/inventory_fact_1998/inventory_fact_1998.csv
    drwxr-xr-x   - hive supergroup          0 2015-09-08 10:20 /user/hive/product
    -rw-r--r--   3 hive supergroup     153791 2015-09-08 10:20 /user/hive/product/product.csv
    drwxr-xr-x   - hive supergroup          0 2015-09-08 10:19 /user/hive/product_class
    -rw-r--r--   3 hive supergroup       5043 2015-09-08 10:19 /user/hive/product_class/product_class.csv
    drwxr-xr-x   - hive supergroup          0 2015-09-08 10:19 /user/hive/time_by_day
    -rw-r--r--   3 hive supergroup      43940 2015-09-08 10:19 /user/hive/time_by_day/time_by_day.csv
    drwxr-xr-x   - hive supergroup          0 2015-09-08 08:25 /user/hive/warehouse

And we can read inside one file with 

    hive@plugin-2:/home/ubuntu$ hdfs dfs -cat /user/hive/product_class/product_class.csv
    1,Nuts,Specialty,Produce,Food
    2,Shellfish,Seafood,Seafood,Food
    3,Canned Fruit,Fruit,Canned Products,Food
    4,Spices,Baking Goods,Baking Goods,Food
    5,Pasta,Starchy Foods,Starchy Foods,Food
    6,Yogurt,Dairy,Dairy,Food
    7,Coffee,Dry Goods,Baking Goods,Drink
    8,Deli Meats,Meat,Deli,Food
    9,Ice Cream,Frozen Desserts,Frozen Foods,Food

Now we can also use the HiveQL language. Hortonworks wrote a nice manual [here](http://hortonworks.com/blog/hive-cheat-sheet-for-sql-users/). Let's run the same query we ran for MongoDB: 

    hive@plugin-2:/home/ubuntu$ hive -e 'select * from product where product_class_id = 9'

    Logging initialized using configuration in jar:file:/usr/lib/hive/lib/hive-common-1.0.0.jar!/hive-log4j.properties
    SLF4J: Class path contains multiple SLF4J bindings.
    SLF4J: Found binding in [jar:file:/usr/lib/hadoop/share/hadoop/common/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
    SLF4J: Found binding in [jar:file:/usr/lib/hive/lib/hive-jdbc-1.0.0-standalone.jar!/org/slf4j/impl/StaticLoggerBinder.class]
    SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
    SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
    OK
    9   103 Golden  Golden Ice Cream    46069397330 0.95    9.81    8.81    true    false   13  8   6.22    15.8    11.8
    9   104 Golden  Golden Ice Cream Sandwich   49550614953 3.89    12.3    10.3    false   true    11  8   9.93    17.4    17.9
    9   109 Golden  Golden Popsicles    51792051196 3.95    19.0    16.0    false   false   11  12  6.69    10.4    7.67
    9   414 Big Time    Big Time Ice Cream  33460944294 2.77    19.9    16.8    true    true    3   12  12.0    19.9    16.3
    9   415 Big Time    Big Time Ice Cream Sandwich 80798811316 2.91    17.4    16.3    true    true    6   10  21.9    18.9    16.5
    9   420 Big Time    Big Time Popsicles  41470299363 2.27    20.6    19.6    true    true    29  12  15.0    9.4 9.94
    9   725 Imagine Imagine Ice Cream   58714897036 1.49    7.33    5.32    false   false   4   14  21.9    14.8    3.48
    9   726 Imagine Imagine Ice Cream Sandwich  92958348393 3.21    8.47    6.47    false   true    5   9   20.1    19.6    10.0
    9   731 Imagine Imagine Popsicles   92913083434 3.81    13.7    10.6    false   false   9   11  9.89    4.82    20.1
    9   1041    PigTail PigTail Ice Cream   81180350184 0.71    20.0    18.0    false   true    2   7   11.1    22.7    4.03
    9   1042    PigTail PigTail Ice Cream Sandwich  86948269009 1.15    16.6    14.6    true    false   14  6   17.6    17.2    16.8
    9   1047    PigTail PigTail Popsicles   34525341391 3.23    10.0    8.0 true    false   16  13  15.5    13.7    5.81
    9   1352    Carrington  Carrington Ice Cream    84529367089 2.65    17.7    14.7    true    true    18  10  16.3    20.4    22.3
    9   1353    Carrington  Carrington Ice Cream Sandwich   44153935313 2.24    13.9    12.8    true    false   19  7   17.7    20.4    22.9
    9   1358    Carrington  Carrington Popsicles    40161059498 2.1 11.5    8.5 false   false   13  8   16.4    7.24    17.9
    Time taken: 1.246 seconds, Fetched: 15 row(s)



## Using Cassandra 

We run all configuration and scripts on cassandra/0. The command line to interact with Cassandra is cqlsh, and you'll need credentials to use it. These are stored in /root/.cassandra/cqlshrc, and only visible by the root user. So from your client you can do: 

    $ juju ssh cassandra/0 sudo cat /root/.cassandra/cqlshrc
    [authentication]
    username = YYYYYYY
    password = XXXXXXX

    [connection]
    hostname = X.X.X.X
    port = 9042

Now that you have your credentials, from the CLI you can run on the cassandra/0 unit

    $ cqlsh -u YYYYYYY -p XXXXXXX
    Connected to juju at 127.0.0.1:9042.
    [cqlsh 5.0.1 | Cassandra 2.1.9 | CQL spec 3.2.0 | Native protocol v3]
    Use HELP for help.
    juju_cassandra_0@cqlsh> 

So this is the prompt for cqlsh. Now you can run a few commands to discover what's in the database: 

    juju_cassandra_0@cqlsh> describe keyspaces;

    foodmart  system_traces  system_auth  system

So here we can see that the foodmart dataset has been imported. Let's look at what's inside of it:

    juju_cassandra_0@cqlsh> describe keyspace foodmart

    CREATE KEYSPACE foodmart WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}  AND durable_writes = true;

    CREATE TABLE foodmart.product (
        product_id bigint PRIMARY KEY,
        brand_name text,
        cases_per_pallet int,
        gross_weight decimal,
        low_fat int,
        net_weight decimal,
        product_class_id bigint,
        product_name text,
        recyclable_package int,
        shelf_depth decimal,
        shelf_height decimal,
        shelf_width decimal,
        sku bigint,
        srp decimal,
        units_per_case int
    ) WITH bloom_filter_fp_chance = 0.01
        AND caching = '{"keys":"ALL", "rows_per_partition":"NONE"}'
        AND comment = ''
        AND compaction = {'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy'}
        AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
        AND dclocal_read_repair_chance = 0.1
        AND default_time_to_live = 0
        AND gc_grace_seconds = 864000
        AND max_index_interval = 2048
        AND memtable_flush_period_in_ms = 0
        AND min_index_interval = 128
        AND read_repair_chance = 0.0
        AND speculative_retry = '99.0PERCENTILE';

        .....

This is basically the content of our foodmart.cassandra file

For more information and use of the CLI for Cassandra, refer to [the official page](http://docs.datastax.com/en/cql/3.1/cql/cql_reference/cqlCommandsTOC.html)

# Sample Outputs
## Bootstrapping

    :~$ ./bin/00-bootstrap.sh 
    [Mon Aug 31 15:03:58 CEST 2015] [demo] [local0.debug] : Validating dependencies
    [Mon Aug 31 15:03:58 CEST 2015] [demo] [local0.debug] : Successfully switched to spagobi
    [Mon Aug 31 15:10:21 CEST 2015] [demo] [local0.debug] : Succesfully bootstrapped spagobi
    [Mon Aug 31 15:10:39 CEST 2015] [demo] [local0.debug] : Successfully deployed juju-gui to machine-0
    [Mon Aug 31 15:10:41 CEST 2015] [demo] [local0.info] : Juju GUI now available on https://X.X.X.X with user admin:XXXX
    [Mon Aug 31 15:11:25 CEST 2015] [demo] [local0.debug] : Bootstrapping process finished for spagobi. You can safely move to deployment.


## Deployment

    :~$ ./bin/01-deploy-spagobi.sh 
    [Mon Aug 31 15:17:52 CEST 2015] [demo] [local0.debug] : Successfully switched to spagobi
    [Mon Aug 31 15:18:11 CEST 2015] [demo] [local0.debug] : Successfully deployed hdfs-master
    [Mon Aug 31 15:18:17 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2 root-disk=32G" for hdfs-master
    [Mon Aug 31 15:18:38 CEST 2015] [demo] [local0.debug] : Successfully deployed yarn-master
    [Mon Aug 31 15:18:44 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=2G cpu-cores=2" for yarn-master
    [Mon Aug 31 15:19:05 CEST 2015] [demo] [local0.debug] : Successfully deployed zookeeper
    [Mon Aug 31 15:19:10 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=2G cpu-cores=2" for zookeeper
    [Mon Aug 31 15:19:32 CEST 2015] [demo] [local0.debug] : Successfully added 2 units of zookeeper
    [Mon Aug 31 15:19:53 CEST 2015] [demo] [local0.debug] : Successfully deployed compute-slave
    [Mon Aug 31 15:19:59 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2 root-disk=32G" for compute-slave
    [Mon Aug 31 15:20:07 CEST 2015] [demo] [local0.debug] : Successfully deployed plugin
    [Mon Aug 31 15:20:32 CEST 2015] [demo] [local0.debug] : Successfully deployed hbase-master
    [Mon Aug 31 15:20:37 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2" for hbase-master
    [Mon Aug 31 15:20:55 CEST 2015] [demo] [local0.debug] : Successfully deployed hbase-regionserver
    [Mon Aug 31 15:21:02 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2" for hbase-regionserver
    [Mon Aug 31 15:21:04 CEST 2015] [demo] [local0.debug] : Successfully created relation between yarn-master and hdfs-master
    [Mon Aug 31 15:21:06 CEST 2015] [demo] [local0.debug] : Successfully created relation between compute-slave and yarn-master
    [Mon Aug 31 15:21:09 CEST 2015] [demo] [local0.debug] : Successfully created relation between compute-slave and hdfs-master
    [Mon Aug 31 15:21:11 CEST 2015] [demo] [local0.debug] : Successfully created relation between plugin and yarn-master
    [Mon Aug 31 15:21:13 CEST 2015] [demo] [local0.debug] : Successfully created relation between plugin and hdfs-master
    [Mon Aug 31 15:21:16 CEST 2015] [demo] [local0.debug] : Successfully created relation between hbase-master and plugin
    [Mon Aug 31 15:21:18 CEST 2015] [demo] [local0.debug] : Successfully created relation between hbase-regionserver and plugin
    [Mon Aug 31 15:21:20 CEST 2015] [demo] [local0.debug] : Successfully created relation between zookeeper and hbase-master
    [Mon Aug 31 15:21:22 CEST 2015] [demo] [local0.debug] : Successfully created relation between zookeeper and hbase-regionserver
    [Mon Aug 31 15:21:24 CEST 2015] [demo] [local0.debug] : Successfully created relation between hbase-master:master and hbase-regionserver:regionserver
    [Mon Aug 31 15:21:49 CEST 2015] [demo] [local0.debug] : Successfully deployed hive
    [Mon Aug 31 15:21:55 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=2G cpu-cores=2" for hive
    [Mon Aug 31 15:22:13 CEST 2015] [demo] [local0.debug] : Successfully deployed mysql-hive
    [Mon Aug 31 15:22:19 CEST 2015] [demo] [local0.debug] : Successfully set constraints "" for mysql-hive
    [Mon Aug 31 15:22:23 CEST 2015] [demo] [local0.debug] : Successfully created relation between hive and plugin
    [Mon Aug 31 15:22:25 CEST 2015] [demo] [local0.debug] : Successfully created relation between hive and mysql-hive
    [Mon Aug 31 15:22:47 CEST 2015] [demo] [local0.debug] : Successfully deployed spark
    [Mon Aug 31 15:22:54 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2" for spark
    [Mon Aug 31 15:22:57 CEST 2015] [demo] [local0.debug] : Successfully created relation between spark and plugin
    [Mon Aug 31 15:23:20 CEST 2015] [demo] [local0.debug] : Successfully deployed cassandra
    [Mon Aug 31 15:23:26 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2" for cassandra
    [Mon Aug 31 15:23:49 CEST 2015] [demo] [local0.debug] : Successfully added 2 units of cassandra
    [Mon Aug 31 15:24:12 CEST 2015] [demo] [local0.debug] : Successfully deployed mongodb
    [Mon Aug 31 15:24:18 CEST 2015] [demo] [local0.debug] : Successfully set constraints "mem=4G cpu-cores=2" for mongodb

## Reset

    :~$ ./bin/50-reset.sh 
    [Thu Aug 27 14:09:57 CEST 2015] [demo] [local0.debug] : Successfully switched to spagobi
    [Thu Aug 27 14:12:22 CEST 2015] [demo] [local0.debug] : Successfully reset spagobi

