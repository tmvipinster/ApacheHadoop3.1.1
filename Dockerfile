FROM centos:7
MAINTAINER Vipin

USER root

# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys


# java
RUN curl -LO 'https://mirrors.huaweicloud.com/java/jdk/8u191-b12/jdk-8u191-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-8u191-linux-x64.rpm
RUN rm jdk-8u191-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java

# download native support
RUN mkdir -p /tmp/native
RUN curl -L https://github.com/dvoros/docker-hadoop-build/releases/download/v3.1.1/hadoop-native-64-3.1.1.tgz | tar -xz -C /tmp/native

# hadoop
RUN curl -sk https://archive.apache.org/dist/hadoop/core/hadoop-3.1.1/hadoop-3.1.1.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-3.1.1 hadoop

ENV HADOOP_HOME /usr/local/hadoop
ENV HDFS_NAMENODE_USER root
ENV HDFS_DATANODE_USER root
ENV HDFS_SECONDARYNAMENODE_USER root
ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop

ENV HADOOP_CLIENT_OPTS -Xmx4096m


RUN echo "JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN echo "HADOOP_HOME=$HADOOP_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

RUN mkdir $HADOOP_HOME/input
RUN cp $HADOOP_HOME/etc/hadoop/*.xml $HADOOP_HOME/input

# pseudo distributed
ADD core-site.xml.template $HADOOP_HOME/etc/hadoop/core-site.xml.template
RUN sed s/HOSTNAME/localhost/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml

# fixing the libhadoop.so like a boss
RUN rm -rf /usr/local/hadoop/lib/native
RUN mv /tmp/native /usr/local/hadoop/lib

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

# Make Hadoop executables available on PATH
ENV PATH $PATH:$HADOOP_HOME/bin

# Adding startup files
RUN mkdir /etc/docker-startup
ADD init.sh /etc/docker-startup/init.sh
ADD entrypoint.sh /etc/docker-startup/entrypoint.sh
ADD bootstrap.sh /etc/docker-startup/bootstrap.sh
RUN chown -R root:root /etc/docker-startup
RUN chmod -R 700 /etc/docker-startup

# This creates initial directories, only run this during image building
RUN /etc/docker-startup/init.sh

# Downstream images can use this too start Hadoop services
ENV BOOTSTRAP /etc/docker-startup/bootstrap.sh

CMD ["/etc/docker-startup/entrypoint.sh"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122
