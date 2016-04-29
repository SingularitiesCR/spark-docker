FROM java:openjdk-8-jre
MAINTAINER Singularities

# Versions
ENV HADOOP_VERSION=2.7.2 \
  SPARK_VERSION=1.6.1

# Set homes
ENV SPARK_HOME=/usr/local/spark \
  HADOOP_HOME=/usr/local/hadoop-$HADOOP_VERSION

# Install dependencies and create user
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install \
    -yq --no-install-recommends \
    curl netcat \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
  && addgroup --system spark \
  && adduser --system --no-create-home --disabled-password --shell /bin/false \
    spark \
  && adduser spark spark

# Install Hadoop
RUN mkdir -p $HADOOP_HOME \
  && curl -sSL \
    http://mirrors.ocf.berkeley.edu/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
    | tar -xz -C $HADOOP_HOME --strip-components 1 \
  && mkdir -p /opt/hdfs
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop \
  HADOOP_LIBEXEC_DIR=$HADOOP_HOME/libexec \
  PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Copy Hadoop configuration
VOLUME /opt/hdfs/data
COPY /hadoop/*.xml $HADOOP_CONF_DIR/
RUN sed -i.bak "s|\[JAVA_HOME\]|${JAVA_HOME}|g" $HADOOP_CONF_DIR/core-site.xml \
  && rm -f $HADOOP_CONF_DIR/core-site.xml.bak \
  && sed -i.bak "s/hadoop-daemons.sh/hadoop-daemon.sh/g" $HADOOP_HOME/sbin/start-dfs.sh \
  && rm -f $HADOOP_HOME/sbin/start-dfs.sh.bak \
  && sed -i.bak "s/hadoop-daemons.sh/hadoop-daemon.sh/g" $HADOOP_HOME/sbin/stop-dfs.sh \
  && rm -f $HADOOP_HOME/sbin/stop-dfs.sh.bak \
  && chown -R spark:spark $HADOOP_HOME \
  && chown -R spark:spark /opt/hdfs

# Install Spark
RUN mkdir -p $SPARK_HOME \
  && curl -sSL \
    http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION-bin-without-hadoop.tgz \
    | tar -xz -C $SPARK_HOME --strip-components 1 \
  && rm -rf $SPARK_HOME/examples \
  && echo "export SPARK_DIST_CLASSPATH=\$(hadoop classpath)" >> /etc/environment \
  && chown -R spark:spark $SPARK_HOME
ENV PATH=$PATH:$SPARK_HOME/bin

# Set entrypoint
COPY entrypoint.sh /opt/entrypoint.sh
USER spark
ENTRYPOINT ["/opt/entrypoint.sh"]

# Expose ports
EXPOSE 6066 7077 8020 8080 8081 19888 50010 50020 50070 50075 50090
