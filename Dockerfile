FROM phusion/baseimage:0.9.9
MAINTAINER Seid Adem <seid.adem@gmail.com>

# Set correct environment variables.
#=================
# Locale settings
#=================
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
RUN locale-gen en_US.UTF-8 \
  && dpkg-reconfigure --frontend noninteractive locales \
  && apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    language-pack-en \
  && rm -rf /var/lib/apt/lists/*

#===================
# Timezone settings
#===================
ENV TZ "US/Pacific"
RUN echo "US/Pacific" | sudo tee /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata


# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

#=================
# Install some tools
#=================
RUN apt-get update && apt-get install -y \ 
    wget \
    vim 

#=================
# Install jdk
#=================
RUN apt-get update
RUN apt-get install -y default-jdk


#=================
# Install nodejs 
#=================
ENV NODE_VERSION v0.10.26
RUN \
cd /tmp && \
wget http://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.gz && \
tar -zxf node-$NODE_VERSION-linux-x64.tar.gz && \
cd node-$NODE_VERSION-linux-x64 && \
cp -prf bin/* /usr/local/bin/ && \
cp -prf lib/* /usr/local/lib/ && \
cp -prf share/* /usr/local/share/

#=================
# Install npm 
#=================
RUN apt-get install -y npm
RUN cd usr/bin; ln -s nodejs node; cd ../..

#=================
# Install protractor 
#=================
RUN npm install -g protractor
RUN webdriver-manager update


#==============
# VNC and Xvfb
#==============
RUN apt-get update -qqy \
  && apt-get -qqy install \
    x11vnc \
    xvfb \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p ~/.vnc \
  && x11vnc -storepasswd secret ~/.vnc/passwd


#=======
# Fonts
#=======
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    fonts-ipafont-gothic \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    xfonts-scalable \
  && rm -rf /var/lib/apt/lists/*


#==========
# Selenium
#==========
RUN  mkdir -p /opt/selenium \
  && wget --no-verbose http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar -O /opt/selenium/selenium-server-standalone.jar

#==================
# PhantomJS magic.
# this package is necessary to prevent PhantomJS 
# from failing silently in a very annoying fashion
#==================
RUN apt-get install -y libfontconfig1-dev


#==================
# Chrome webdriver
#==================
RUN apt-get update -qqy 
  && apt-get install -y chromium-browser


#=================
# Mozilla Firefox
#=================
#RUN apt-get update -qqy 
#  && apt-get install -y firefox
ENV FIREFOX_VERSION 33.0
RUN cd /usr/local && \
wget http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/33.0/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 && \
tar xvjf firefox-$FIREFOX_VERSION.tar.bz2 && \
ln -s /usr/local/firefox/firefox /usr/bin/firefox


#=================
# Phantomjs
#=================
RUN npm install -g phantomjs




#========================================
# Add normal user with passwordless sudo
#========================================
RUN sudo useradd seluser --shell /bin/bash --create-home \
  && sudo usermod -a -G sudo seluser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

#====================================================================
# Script to run selenium standalone server for Chrome and/or Firefox
#====================================================================
COPY ./bin/*.sh /opt/selenium/
RUN  chmod +x /opt/selenium/*.sh


#============================
# Some configuration options
#============================
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV SELENIUM_PORT 4444
ENV DISPLAY :20.0


#================================
# Expose Container's Directories
#================================
VOLUME /var/log


#================================
# Expose Container's Ports
#================================
EXPOSE 4444 5900

#===================
# CMD or ENTRYPOINT
#===================
# Start a selenium standalone server for Chrome and/or Firefox
# CMD ["/opt/selenium/entry_point.sh"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*