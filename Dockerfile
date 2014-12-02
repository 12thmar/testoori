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
    vim \
    gcc \
    make \
    openssl \
    screen \
    unzip \
    xclip \
    zip

#=================              
#                                                                                (0)
#================= 
# Add Google Chrome's repo to sources.list
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee -a /etc/apt/sources.list
 
# Install Google's public key used for signing packages (e.g. Chrome)
# (Source: http://www.google.com/linuxrepositories/)
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -


#=================
# Install nodejs                                                                (1)
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

RUN npm install -g requirejs
RUN npm install -g grunt-cli
RUN npm install -g karma
RUN npm install -g request

#==============
# Java
# Minimal runtime used for executing non GUI Java programs                     (2)-updated -B
#==============
RUN apt-get update -qqy && \
    apt-get -qqy --no-install-recommends install openjdk-7-jre-headless && \ 
    rm -rf /var/lib/apt/lists/*


#=================
# Install protractor 
#=================
## RUN npm install -g protractor
ENV PROTRACTOR_VERSION 1.0.0
RUN npm install -g protractor@$PROTRACTOR_VERSION


#=======
# Fonts                                                                        (3)-updated -B
#=======
RUN apt-get update -qqy && \
    apt-get -qqy --no-install-recommends install \
      fonts-ipafont-gothic \
      xfonts-100dpi \
      xfonts-75dpi \
      xfonts-cyrillic \
      xfonts-scalable \
      x11-apps 


#==============
#  Xvfb                                                                        (2)-updated -A
#==============
RUN apt-get update -qqy && \ 
    apt-get -qqy install xvfb && \
    rm -rf /var/lib/apt/lists/* 



#==============
# Install Packages Required by Browsers                                        (3)
#==============
## RUN sudo apt-get install -y 
##    x11-xkb-utils \
##    xfonts-100dpi \
##    xfonts-75dpi \
##    xfonts-scalable \ 
##    xserver-xorg-core \
##    dbus-x11 \
##    libfontconfig1-dev \
##    libxi6 \
##    libgconf-2-4 



#==========
# Selenium                                                                      (7)-updated
#==========
##############
# version 2.44
##############
# RUN mkdir -p /opt/selenium \
# && wget --no-verbose http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar -O /opt/selenium/selenium-server-standalone.jar
##############
# version 2.42
##############
ENV SELENIUM_VERSION_PRE 2.42
ENV SELENIUM_VERSION 2.42.0
npm install selenium-standalone@SELENIUM_VERSION
## RUN \
## wget --no-verbose  http://selenium-release.storage.googleapis.com/$SELENIUM_VERSION_PRE/selenium-server-standalone-$SELENIUM_VERSION.jar -O
##                /usr/local/lib/node_modules/protractor/selenium-server-standalone-$SELENIUM_VERSION.jar

RUN /usr/local/lib/node_modules/protractor/bin/webdriver-manager update



#==================
# Chrome webdriver
#==================
ENV CHROME_DRIVER_VERSION 2.10.1
RUN npm install -g chromedriver@CHROME_DRIVER_VERSION


#==================
# Chrome webdriver
#==================
## ENV CHROME_DRIVER_VERSION 2.10
## RUN cd /tmp && \
##    wget --no-verbose -O chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip && \
##    cd /opt/selenium && \
##    rm -rf chromedriver && \
##    unzip /tmp/chromedriver_linux64.zip && \
##    rm /tmp/chromedriver_linux64.zip && \
##    mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION && \
##    chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION && \
##    ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver





#==============
# Install Browsers                                                             (4)-updated 
#==============

#=========
# fluxbox
# A fast, lightweight and responsive window manager                            (4)-updated -A
#=========
## RUN apt-get update -qqy && \
##    apt-get -qqy --no-install-recommends install fluxbox && \
##    rm -rf /var/lib/apt/lists/*

#===============
# Google Chrome                                                                (4)-updated -B
#===============
## RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
## echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list 
## RUN apt-get update -qqy && \
##    apt-get -qqy install google-chrome-stable && \
##    rm -rf /var/lib/apt/lists/* && \
##    rm /etc/apt/sources.list.d/google-chrome.list


#=================
# Mozilla Firefox                                                               (4)-updated -C
#=================
## RUN apt-get update -qqy && \
## apt-get -qqy --no-install-recommends install \
##   firefox \
##   && rm -rf /var/lib/apt/lists/*



#========================================
# Add normal user with passwordless sudo
#========================================
## RUN sudo useradd seluser --shell /bin/bash --create-home && \
##    sudo usermod -a -G sudo seluser && \
##    echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers


#====================================================================
# Script to run selenium standalone server for Chrome and/or Firefox
#====================================================================
COPY ./bin/*.sh /opt/selenium/
RUN chmod +x /opt/selenium/*.sh


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
CMD ["/opt/selenium/entry_point.sh"]