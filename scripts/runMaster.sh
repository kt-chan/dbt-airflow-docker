#!/usr/bin/env bash

cd ${SPARK_HOME}
./sbin/start-master.sh 

tail -f ${SPARK_HOME}/logs/Spark.log