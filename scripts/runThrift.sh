#!/usr/bin/env bash

cd ${SPARK_HOME}

## ## # Spark 3.2 standard 
## ./bin/spark-submit --master spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT \
## --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
## >> /tmp/logs/start-thriftserver.out & 


## ##Spark 3.2 with hudi table [this does not work for spark thrift sql]
##  ./bin/spark-submit --master spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT \
##  --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
##  >> /tmp/logs/start-thriftserver.out & 
## 

## test for local mode
 ./bin/spark-submit  \
 --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 

tail -f ./logs/Spark.log