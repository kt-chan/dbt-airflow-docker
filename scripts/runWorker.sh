#!/usr/bin/env bash

cd ${SPARK_HOME}
./sbin/start-slave.sh spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT}

tail -f ${SPARK_HOME}/logs/Spark.log