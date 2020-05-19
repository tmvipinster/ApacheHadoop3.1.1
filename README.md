# Apache Hadoop Docker image

[![DockerPulls](https://img.shields.io/docker/pulls/dvoros/hadoop.svg)](https://registry.hub.docker.com/u/dvoros/hadoop/)
[![DockerStars](https://img.shields.io/docker/stars/dvoros/hadoop.svg)](https://registry.hub.docker.com/u/dvoros/hadoop/)

_Note: this is the master branch - for a particular Hadoop version always check the related branch_

# Build the image

If you'd like to try directly from the Dockerfile you can build the image as:

```
docker build -t user_name/hadoop:latest .
```

# Start a container

In order to use the Docker image you have just build or pulled use:

**Make sure that SELinux is disabled on the host. If you are using boot2docker you don't need to do anything.**

docker run -it user_name/hadoop:latest /etc/bootstrap.sh -bash

