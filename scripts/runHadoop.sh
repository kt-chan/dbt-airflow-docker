#!/usr/bin/env bash

sudo service ssh start

if [ ! -d "/tmp/hadoop-hdfs/dfs/name" ]; then
         $HADOOP_HOME/bin/hdfs namenode -format -force
fi

sudo mkdir -p $HADOOP_HOME/logs
sudo chown hdfs:hdfs $HADOOP_HOME/logs
sudo chmod 755 $HADOOP_HOME/logs

cd $HADOOP_HOME
sed -i -e "s/localhost/$HOSTNAME/g"  $HADOOP_HOME/etc/hadoop/core-site.xml
./sbin/start-dfs.sh

sleep 10

hdfs dfs -mkdir -p /data
hdfs dfs -put -f /sample/*.csv /data/.

tail -f /dev/null