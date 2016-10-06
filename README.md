# Apache Spark

An [Apache Spark](http://spark.apache.org/) container image. The image is meant to be used for creating an standalone cluster with multiple workers.

- [`1.5` (Dockerfile)](https://github.com/SingularitiesCR/spark-docker/blob/1.5/Dockerfile)
- [`1.6` (Dockerfile)](https://github.com/SingularitiesCR/spark-docker/blob/1.6/Dockerfile)

## Custom commands

This image contains a script named `start-spark` (included in the PATH). This script is used to initialize the master and the workers.

### HDFS user

The custom commands require an HDFS user to be set. The user's name if read from the `HDFS_USER` environment variable and the user is automatically created by the commands.

### Starting a master

To start a master run the following command:

```sh
start-spark master
```

### Starting a worker

To start a worker run the following command:

```sh
start-spark worker [MASTER]
```

### Deprecated commands

The commands `master` and `worker` from previous versions of the image are maintained for compatibility but should not be used.


## Creating a Cluster with Docker Compose

The easiest way to create a standalone cluster with this image is by using [Docker Compose](https://docs.docker.com/compose). The following snippet can be used as a `docker-compose.yml` for a simple cluster:

```YAML
```

*All Spark and HDFS ports are exposed by the image. In the example compose file we only map the Spark submit ports and the ports for the web clients.*

### Persistence

The image has a volume mounted at `/opt/hdfs`. To maintain states between restarts, mount a volume at this location. This should be done for the master and the workers.

### Scaling

If you wish to increase the number of workers scale the `sparkworker` service by running the `scale` command like follows:

```sh
docker-compose scale sparkworker=2
```

The workers will automatically register themselves with the master.
