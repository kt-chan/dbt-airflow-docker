#!/usr/bin/env bash

cd ${SPARK_HOME}
./bin/spark-class org.apache.spark.deploy.worker.Worker spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} >> ./logs/spark-worker.out