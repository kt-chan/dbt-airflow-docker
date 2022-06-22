#!/usr/bin/env bash

cd ${SPARK_HOME}
./bin/spark-class org.apache.spark.deploy.worker.Worker spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} >> /tmp/logs/spark-worker.out

tail -f /dev/null