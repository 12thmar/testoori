FROM ubuntu:latest
MAINTAINER Seid Adem <seid.adem@gmail.com>

RUN apt-get update && apt-get install -y \
    aufs-tools \
    automake \
    btrfs-tools \
    build-essential \
    curl \
    git \
    --no-install-recommends


#install nodejs with Ubuntu:
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN cd usr/bin; ln -s nodejs node; cd ../..

RUN npm install -g protractor
RUN webdriver-manager update
