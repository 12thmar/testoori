FROM ubuntu:latest
MAINTAINER Seid Adem "seid.adem@gmail.com"

RUN apt-get update && apt-get install -y \
    aufs-tools \
    automake \
    btrfs-tools \
    build-essential \
    curl \
    dpkg-sig \
    git \
    iptables \
    libapparmor-dev \
    libcap-dev \
    libsqlite3-dev \
    lxc=1.0* \
    mercurial \
    parallel \
    reprepro \
    ruby1.9.1 \
    ruby1.9.1-dev \
    s3cmd=1.1.0* \
    --no-install-recommends


#install nodejs with Ubuntu:
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN cd usr/bin; ln -s nodejs node; cd ../..
