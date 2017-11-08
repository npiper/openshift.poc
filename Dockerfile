FROM centos:7

RUN yum -y -q install curl vim openssh openssh-clients

WORKDIR /usr/local/bin

RUN curl https://s3.eu-west-2.amazonaws.com/binaries.dev.neilpiper.me/oc-3.6.173.0.21-linux.tar.gz | tar xvz

RUN mkdir -p /root/.ssh 
RUN ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa 

WORKDIR /
