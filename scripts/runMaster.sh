#!/usr/bin/env bash

cd ${SPARK_HOME}
./sbin/start-thriftserver.sh  >> ./logs/start-thriftserver.out
./bin/spark-class org.apache.spark.deploy.master.Master --ip $SPARK_MASTER_HOST --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> ./logs/spark-master.out