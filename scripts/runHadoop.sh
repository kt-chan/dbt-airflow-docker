#!/usr/bin/env bash

sudo service ssh start

sudo rm -rf /tmp/hadoop-hdfs/dfs/*
$HADOOP_HOME/bin/hdfs namenode -format -force

# if [ ! -d "/tmp/hadoop-hdfs/dfs/name" ]; then
#         $HADOOP_HOME/bin/hdfs namenode -format -force
# fi

sudo mkdir -p $HADOOP_HOME/logs
sudo chown hdfs:hdfs $HADOOP_HOME/logs
sudo chmod 755 $HADOOP_HOME/logs

cd $HADOOP_HOME
sed -i -e "s/localhost/$HOSTNAME/g"  $HADOOP_HOME/etc/hadoop/core-site.xml
./sbin/start-dfs.sh

sleep 10

hdfs dfs -mkdir -p /data
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -put -f /sample/* /data/.

tail -f /dev/null