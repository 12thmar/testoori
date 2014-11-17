FROM ubuntu:14.04
MAINTAINER Seid Adem <seid.adem@gmail.com>

# I am not sure about the belwo setting
RUN apt-get update && apt-get install -y \ 
    curl \
    git \
    wget
#
# Install git client, jdk
#
RUN apt-get install -y git
RUN apt-get update
RUN apt-get install -y default-jdk


#install nodejs with Ubuntu:
RUN apt-get install -y nodejs
##RUN \
##cd /tmp && \
##wget http://nodejs.org/dist/node-latest.tar.gz && \
##tar xvzf node-latest.tar.gz && \
##rm -f node-latest.tar.gz && \
##cd node-v* && \
##./configure && \
##CXX="g++ -Wno-unused-local-typedefs" make && \
##CXX="g++ -Wno-unused-local-typedefs" make install && \
##cd /tmp && \
##rm -rf /tmp/node-v* && \
##echo '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

RUN apt-get install -y npm
RUN cd usr/bin; ln -s nodejs node; cd ../..

RUN npm install -g protractor
RUN webdriver-manager update

ENV SELENIUM_VERSION 2.43.1
ENV SELENIUM_NPM_VERSION 2.43.1-2.9.0

#
# Create a Xvfb init.d deamon
#
RUN apt-get install -y xvfb
# Copy over service script
ADD /selenium/xvfb /etc/init.d/xvfb
#ADD xvfb /etc/init.d/
RUN chown root:root /etc/init.d/xvfb
RUN chmod ugo+x /etc/init.d/xvfb
RUN update-rc.d xvfb defaults

#
# Packages to keep Chrome and FF happy.
#
RUN apt-get install -y x11-xkb-utils xfonts-100dpi xfonts-75dpi
RUN apt-get install -y xfonts-scalable xserver-xorg-core
RUN apt-get update
RUN apt-get install -y dbus-x11

#
# PhantomJS magic.
#
RUN apt-get install -y libfontconfig1-dev

#
# Install Browsers.
#
RUN apt-get install -y chromium-browser firefox
RUN npm install -g phantomjs

#
# Install Selenium and chromedriver.
#
RUN npm install --production selenium-standalone@$SELENIUM_NPM_VERSION -g
RUN npm install -g chromedriver

#
# Setup WORKINGDIR so that docker image can be easily tested.
#
RUN mkdir -p /srcTest
ADD . srcTest
WORKDIR srcTest

RUN chmod ugo+x testSelenium.sh

#
# Install Selenium locally.
#
RUN npm install --production selenium-standalone@$SELENIUM_NPM_VERSION

