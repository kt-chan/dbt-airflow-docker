#!/usr/bin/env bash

cd ${SPARK_HOME}
./bin/spark-class org.apache.spark.deploy.master.Master --ip $SPARK_MASTER_HOST --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> /tmp/logs/spark-master.out &


tail -f /dev/null