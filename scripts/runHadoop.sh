#!/usr/bin/env bash

sudo service ssh start
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

source $HADOOP_HOME/etc/hadoop/hadoop-env.sh


cd $HADOOP_HOME
sudo rm -rf /tmp/hadoop-hdfs/dfs/*
hdfs namenode -format -force
start-dfs.sh

sleep 10

hdfs dfs -mkdir -p /tmp/hive
hdfs dfs -chmod -R 777 /tmp

hdfs dfs -mkdir -p /data
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -put -f /sample/* /data/.

tail -f /dev/null