# Apache Spark

An [Apache Spark](http://spark.apache.org/) container image. The image is meant to be used for creating an standalone cluster with multiple workers.

- [`1.5` (Dockerfile)](https://github.com/SingularitiesCR/spark-docker/blob/1.5/Dockerfile)
- [`1.6` (Dockerfile)](https://github.com/SingularitiesCR/spark-docker/blob/1.6/Dockerfile)
- [`2.0` (Dockerfile)](https://github.com/SingularitiesCR/spark-docker/blob/2.0/Dockerfile)
- [`2.1` (Dockerfile)](https://github.com/SingularitiesCR/spark-docker/blob/2.1/Dockerfile)
- [`2.2` (Dockerfile)](https://github.com/SingularitiesCR/spark-docker/blob/2.2/Dockerfile)

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
version: "2"

services:
  master:
    image: singularities/spark
    command: start-spark master
    hostname: master
    ports:
      - "6066:6066"
      - "7070:7070"
      - "8080:8080"
      - "50070:50070"
  worker:
    image: singularities/spark
    command: start-spark worker master
    environment:
      SPARK_WORKER_CORES: 1
      SPARK_WORKER_MEMORY: 2g
    links:
      - master
```

### Persistence

The image has a volume mounted at `/opt/hdfs`. To maintain states between restarts, mount a volume at this location. This should be done for the master and the workers.

### Scaling

If you wish to increase the number of workers scale the `worker` service by running the `scale` command like follows:

```sh
docker-compose scale worker=2
```

The workers will automatically register themselves with the master.
