FROM ubuntu:16.04

# set environment vars
ENV HADOOP_HOME /home/hduser/hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HDFS_NAMENODE_USER hduser
ENV HDFS_DATANODE_USER hduser
ENV HDFS_SECONDARYNAMENODE_USER hduser
ENV YARN_RESOURCEMANAGER_USER hduser
ENV YARN_NODEMANAGER_USER hduser

RUN \
	apt-get update -y && apt-get install -y \
	sudo \
	vim \
	ssh \
	openjdk-8-jdk

RUN \
	useradd -m hduser && echo "hduser:supergroup" | chpasswd && adduser hduser sudo && echo "hduser     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


WORKDIR /home/hduser

USER hduser

COPY hadoop/hadoop-dist/target/hadoop-3.1.5-SNAPSHOT.tar.gz /home/hduser/hadoop-3.1.5-SNAPSHOT.tar.gz

# download and extract hadoop, set JAVA_HOME in hadoop-env.sh, update path
RUN \
  tar -xzf hadoop-3.1.5-SNAPSHOT.tar.gz && \  
  mv hadoop-3.1.5-SNAPSHOT hadoop && \
  echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
  echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

# create ssh keys
RUN \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
  chmod 0600 ~/.ssh/authorized_keys

# copy hadoop configs
ADD configs/*xml $HADOOP_HOME/etc/hadoop/

# copy ssh config
ADD configs/ssh_config /home/hduser/.ssh/config

# copy script to start hadoop
ADD configs/start-hadoop.sh /home/hduser/start-hadoop.sh

# expose various ports
EXPOSE 8088 8042 9864 9870

# start hadoop
CMD bash start-hadoop.sh



