#!/usr/bin/env bash

# Read environment variables
source /etc/environment

clean_hdfs() {
  rm -rf /opt/hdfs/tmp
  mkdir -p /opt/hdfs/tmp
}

run_master() {
  clean_hdfs
  # Start HDFS name node
  sed -i.bak "s|\[NAMENODE_HOST\]|$(hostname)|g" $HADOOP_CONF_DIR/core-site.xml
  hdfs namenode -format -force
  start-dfs.sh
  hadoop fs -mkdir -p /tmp
  hadoop fs -chmod -R 777 /tmp
  # Run spark master
  spark-class org.apache.spark.deploy.master.Master -h $(hostname)
}

run_worker() {
  clean_hdfs
  # Check master argument
  local master=$1
  if [ -z "${master}" ]; then
    (>&2 echo "Please specify the IP or host for the Spark Master")
    exit 1
  fi
  # Wait for HDFS name node to be online
  while ! nc -z $master 50070; do
    sleep 2;
  done;
  # Start HDFS data node
  sed -i.bak "s|\[NAMENODE_HOST\]|${master}|g" $HADOOP_CONF_DIR/core-site.xml
  hadoop-daemon.sh start datanode
  # Wait for Spark master to be online
  while ! nc -z $master 7077; do
    sleep 2;
  done;
  # Run spark worker
  spark-class org.apache.spark.deploy.worker.Worker spark://$master:7077
}

if [ "$1" == "master" ]; then
  run_master
elif [ "$1" == "worker" ]; then
  run_worker $2
else
  (>&2 echo "Unknown command '$1'")
  exit 1
fi
