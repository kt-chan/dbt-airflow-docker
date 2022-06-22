#!/usr/bin/env bash

cd ${SPARK_HOME}

# Spark 3.2 standard 
./sbin/start-thriftserver.sh --master spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT >> /tmp/logs/start-thriftserver.out & 

## # Spark 3.2 with hudi table [this does not work for spark thrift sql]
## ./bin/spark-submit --master spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT \
## --packages org.apache.hudi:hudi-spark3.2-bundle_2.12:0.11.0 \
## --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 \
## --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' \
## --conf 'spark.sql.extensions=org.apache.spark.sql.hudi.HoodieSparkSessionExtension' \
## --conf 'spark.sql.catalog.spark_catalog=org.apache.spark.sql.hudi.catalog.HoodieCatalog'


tail -f /dev/null