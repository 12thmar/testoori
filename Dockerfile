FROM phusion/baseimage:0.9.9
MAINTAINER Seid Adem <seid.adem@gmail.com>

#================================================
# Customize sources for apt-get
#================================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu precise main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu precise-updates main universe\n" >> /etc/apt/sources.list

#========================
# Miscellaneous packages
# Includes minimal runtime used for executing non GUI Java programs
#========================
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    ca-certificates \
    openjdk-7-jre-headless \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

#==========
# Selenium
#==========
RUN  mkdir -p /opt/selenium \
  && wget --no-verbose http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar -O /opt/selenium/selenium-server-standalone.jar

#========================================
# Add normal user with passwordless sudo
#========================================
RUN sudo useradd seluser --shell /bin/bash --create-home \
  && sudo usermod -a -G sudo seluser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'seluser:secret' | chpasswd


ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

#===================
# Timezone settings
#===================
ENV TZ "US/Pacific"
RUN echo "US/Pacific" | sudo tee /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata

#==============
# VNC and Xvfb
#==============
RUN apt-get update -qqy \
  && apt-get -qqy install \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

#==============================
# Scripts to run Selenium Node
#==============================
COPY bin/entry_point.sh /opt/bin/entry_point.sh
RUN chmod +x /opt/bin/entry_point.sh

#============================
# Some configuration options
#============================
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0


USER root

#===============
# Google Chrome
#===============
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    google-chrome-stable \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/*

#==================
# Chrome webdriver
#==================
ENV CHROME_DRIVER_VERSION 2.13
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

#=========
# Firefox
#=========
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    firefox \
  && rm -rf /var/lib/apt/lists/*


#=================
# Install nodejs & protractor                                                          
#=================
ENV NODE_VERSION v0.10.26
RUN cd /tmp  \
   && wget http://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.gz \
   && tar -zxf node-$NODE_VERSION-linux-x64.tar.gz \
   && cd node-$NODE_VERSION-linux-x64 \
   && cp -prf bin/* /usr/local/bin/ \
   && cp -prf lib/* /usr/local/lib/ \
   && cp -prf share/* /usr/local/share/

RUN npm install -g requirejs
RUN npm install -g grunt-cli
RUN npm install -g karma
RUN npm install -g request
RUN npm install -g protractor

#========================
# Selenium Configuration
#========================
COPY bin/config.json /opt/selenium/config.json

#=================================
# Chrome Launch Script Modication
#=================================
COPY bin/chrome_launcher.sh /opt/google/chrome/google-chrome
RUN chmod +x /opt/google/chrome/google-chrome


#====================================================================
# Script to run selenium standalone server for Chrome and/or Firefox
#====================================================================
# Set up loggin directory for Selenium
RUN \
     mkdir /var/log/selenium && \
     chown seluser:seluser /var/log/selenium


CMD ["/opt/bin/entry_point.sh"]

#=================================
# Imagemagick for screen capture
#=================================
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install curl
  