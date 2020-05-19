# Apache Hadoop Docker image

[![DockerPulls](https://img.shields.io/docker/pulls/dvoros/hadoop.svg)](https://registry.hub.docker.com/u/dvoros/hadoop/)
[![DockerStars](https://img.shields.io/docker/stars/dvoros/hadoop.svg)](https://registry.hub.docker.com/u/dvoros/hadoop/)

_Note: this is the master branch - for a particular Hadoop version always check the related branch_

# Build the image

If you'd like to try directly from the Dockerfile you can build the image as:

```
docker build -t dvoros/hadoop:latest .
```

# Pull the image

The image is also released as an official Docker image from Docker's automated build repository - you can always pull or refer the image when launching containers.

```
docker pull dvoros/hadoop:latest
```

# Start a container

In order to use the Docker image you have just build or pulled use:

**Make sure that SELinux is disabled on the host. If you are using boot2docker you don't need to do anything.**

```
docker run -it dvoros/hadoop:latest /etc/bootstrap.sh -bash
```

## Testing

You can run one of the stock examples:

```
# run mapreduce
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar grep input output 'dfs[a-z.]+'

# check the output
hdfs dfs -cat output/*
```

## Hadoop native libraries, build

The Hadoop build process is no easy task - requires lots of libraries and their right version, protobuf, etc and takes some time - we have simplified all these, made the build and released a 64b version of Hadoop nativelibs [here](https://github.com/dvoros/docker-hadoop-build/releases). (These are automatically pulled during the build of this image.)
