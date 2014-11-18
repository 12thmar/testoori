FROM ubuntu:12.04
MAINTAINER Seid Adem <seid.adem@gmail.com>

# I am not sure about the belwo setting
RUN apt-get update && apt-get install -y \ 
    curl \
    git \
    wget \
    bzip2
#
# Install git client, jdk
#
RUN apt-get install -y git
RUN apt-get update
RUN apt-get install -y default-jdk


#install nodejs with Ubuntu:
#RUN apt-get install -y nodejs
ENV NODE_VERSION v0.10.26
RUN \
cd /tmp && \
wget http://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.gz && \
tar -zxf node-$NODE_VERSION-linux-x64.tar.gz && \
cd node-$NODE_VERSION-linux-x64 && \
cp -prf bin/* /usr/local/bin/ && \
cp -prf lib/* /usr/local/lib/ && \
cp -prf share/* /usr/local/share/

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
##RUN npm install --production selenium-standalone@$SELENIUM_NPM_VERSION -g
RUN npm install -g chromedriver


#
# Install Selenium.
#
RUN \
/usr/sbin/useradd -m -s /bin/bash -d /home/selenium selenium && \
mkdir /usr/local/share/selenium \
wget http://selenium.googlecode.com/files/selenium-server-standalone-2.37.0.jar && \
mv selenium-server-standalone-2.37.0.jar /usr/local/share/selenium && \
chown -R selenium:selenium /usr/local/share/selenium && \
mkdir /var/log/selenium && \
chown selenium:selenium /var/log/selenium

#Place start script into /etc/init.d/selenium, and note that it uses the same DISPLAY value as for the Xvfb
ADD /selenium/selenium /etc/init.d/selenium
RUN chown root:root /etc/init.d/selenium
RUN chmod a+x /etc/init.d/selenium
RUN update-rc.d  /etc/init.d/selenium defaults

#Logfile for the PhantomJS WebDriver
RUN touch /phantomjsdriver.log
RUN chmod 666 /phantomjsdriver.log

#
# Setup WORKINGDIR so that docker image can be easily tested.
#
# RUN mkdir -p /srcTest
# ADD . srcTest
# WORKDIR srcTest

# RUN chmod ugo+x testSelenium.sh

#
# Install Selenium locally.
#
# RUN npm install --production selenium-standalone@$SELENIUM_NPM_VERSION

