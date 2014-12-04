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
RUN apt-get update

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
# Install jdk                                                                  (2)
#==============
RUN apt-get install -y default-jdk

#=================
# Install protractor 
#=================
RUN npm install -g protractor
RUN webdriver-manager update


#==========
# Create a Xvfb init.d deamon                                                  (3)
#==========
RUN apt-get install -y xvfb
# Copy over service script
ADD selenium/xvfb /etc/init.d/
RUN chown root:root /etc/init.d/xvfb
RUN chmod ugo+x /etc/init.d/xvfb
RUN update-rc.d xvfb defaults

#==========
# Packages to keep Chrome and FF happy.                                        (4)
#==========
RUN apt-get install -y x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-cyrillic
RUN apt-get install -y xfonts-scalable xserver-xorg-core
RUN apt-get install -y defoma x-ttcidfont-conf
RUN apt-get update
RUN apt-get install -y dbus-x11

#==========
# PhantomJS magic.                                                             (5)
#==========
RUN apt-get install -y libfontconfig1-dev

#==========
# Install Browsers.                                                            (6)
#==========
RUN apt-get install -y chromium-browser firefox
RUN npm install -g phantomjs


#==========
# Selenium and chromedriver.                                                   (7)                                                                   
#==========
#ENV SELENIUM_VERSION 2.43.1
#ENV SELENIUM_NPM_VERSION 2.43.1-2.9.0

#RUN npm install -g --production selenium-standalone@$SELENIUM_NPM_VERSION 
#RUN npm install -g chromedriver

##############
# version 2.42
##############
ENV SELENIUM_VERSION_PRE 2.42
ENV SELENIUM_VERSION 2.42.0
RUN \
    ln -s /usr/lib/chromium-browser/chromium-browser /usr/bin/google-chrome 
    sudo useradd selenium --shell /bin/bash --create-home &&\
    sudo usermod -a -G sudo selenium && \
    echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers
    wget --no-verbose  http://selenium-release.storage.googleapis.com/$SELENIUM_VERSION_PRE/selenium-server-standalone-$SELENIUM_VERSION.jar -O /usr/local/share/selenium/selenium-server-standalone-$SELENIUM_VERSION.jar 
    chown -R selenium:selenium /usr/local/share/selenium 

ENV CHROMEDRVR_VERSION 2.10
RUN \
wget -N http://chromedriver.storage.googleapis.com/$CHROMEDRVR_VERSION/chromedriver_linux64.zip -P ~/tmp 
unzip ~//tmp/chromedriver_linux64.zip -d ~/tmp
chmod +x ~/tmp/chromedriver 
sudo mv -f ~/Downloads/chromedriver /usr/local/share/chromedriver 
sudo ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver 
sudo ln -s /usr/local/share/chromedriver /usr/bin/chromedriver



#====================================================================
# Script to run selenium standalone server for Chrome and/or Firefox
#====================================================================
#Place start script into /etc/init.d/selenium, 
# and note that it uses the same DISPLAY value as for the Xvfb
ADD /selenium/selenium /etc/init.d/selenium
RUN chown root:root /etc/init.d/selenium
RUN chmod a+x /etc/init.d/selenium
RUN update-rc.d  selenium defaults



#============================
# Some configuration options
# SCREEN_WIDTH 1024
# SCREEN_HEIGHT 768
# SCREEN_DEPTH 16
# DISPLAY 10.0
#============================
ENV SCREEN_WIDTH 1360  
ENV SCREEN_HEIGHT 1020  
ENV SCREEN_DEPTH 24    
ENV SELENIUM_PORT 4444
ENV DISPLAY 20.0      
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
#CMD ["/opt/selenium/entry_point.sh"]