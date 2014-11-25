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


#=================
# Install npm 
#=================
# RUN apt-get install -y npm
# RUN cd usr/bin; ln -s nodejs node; cd ../..

#=================
# Install protractor 
#=================
RUN npm install -g protractor

#==============
# Xvfb                                                                         (2)
# Then place this start script into /etc/init.d/xvfb: 
# Make sure it is executable, owned by root, and that the service definitions are updated: 
#==============
RUN sudo apt-get install -y xvfb
ADD /selenium/xvfb /etc/init.d/xvfb
RUN chown root:root /etc/init.d/xvfb
RUN chmod ugo+x /etc/init.d/xvfb
RUN update-rc.d xvfb defaults

#==============
# Install Packages Required by Browsers                                        (3)
#==============
RUN sudo apt-get install -y x11-xkb-utils xfonts-100dpi xfonts-75dpi
RUN sudo apt-get install -y xfonts-scalable xserver-xorg-core
RUN sudo apt-get install -y dbus-x11


#==============
# Install Browsers                                                             (4)
#==============
sudo apt-get install chromium-browser firefox
sudo npm install -g phantomjs


#==============
# Install WebDriver Implementations                                            (5)
#==============
sudo npm install -g chromedriver

#=================
# Install jdk                                                                  (6)
#=================
RUN apt-get update
RUN apt-get install -y default-jdk

#=================
# Set Up the Selenium Standalone Server as a Service                           (7)
# Then place this start script into /etc/init.d/selenium:
#=================
ENV SELENIUM_VERSION_PRE 2.44
ENV SELENIUM_VERSION 2.44.0
RUN \
/usr/sbin/useradd -m -s /bin/bash -d /home/selenium selenium && \
mkdir /usr/local/share/selenium && \
wget --no-verbose http://selenium-release.storage.googleapis.com/$SELENIUM_VERSION_PRE/selenium-server-standalone-$SELENIUM_VERSION.jar -O /usr/local/share/selenium/selenium && \
chown -R selenium:selenium /usr/local/share/selenium && \
mkdir /var/log/selenium && \
chown selenium:selenium /var/log/selenium && \
sudo mkdir /var/log/selenium && \
sudo chown selenium:selenium /var/log/selenium 

ADD /selenium/selenium /etc/init.d/selenium 
RUN chown root:root /etc/init.d/selenium && \
RUN sudo chmod a+x /etc/init.d/selenium && \
RUN sudo update-rc.d  /etc/init.d/selenium defaults && \

#=================
# Work Around a Protractor / PhantomJS Issue                                 (8)
#=================
RUN sudo touch /phantomjsdriver.log
RUN sudo chmod 666 /phantomjsdriver.log


#=================
# Install Imagemagick or for Snapshots                                       (9)
#=================
sudo apt-get install imagemagick




# Download the selenium standalone server
## CMD ['/usr/local/lib/node_modules/protractor/bin/webdriver-manager install update']





#=======
# Fonts
#=======
##RUN apt-get update -qqy \
##  && apt-get -qqy --no-install-recommends install \
##    fonts-ipafont-gothic \
##    xfonts-100dpi \
##    xfonts-75dpi \
##    xfonts-cyrillic \
##    xfonts-scalable \
##  && rm -rf /var/lib/apt/lists/*


#==========
# Selenium
#==========
##ENV SELENIUM_VERSION 2.44.0
##RUN  mkdir -p /opt/selenium \
## && wget --no-verbose http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-$SELENIUM_VERSION.jar -O /opt/selenium/selenium-server-standalone.jar

#==================
# PhantomJS magic.
# this package is necessary to prevent PhantomJS 
# from failing silently in a very annoying fashion
#==================
# RUN apt-get install -y libfontconfig1-dev


#==================
# Chrome webdriver
#==================
## RUN apt-get update -qqy 
##  && apt-get install -y chromium-browser


#=================
# Mozilla Firefox
#=================
#RUN apt-get update -qqy 
#  && apt-get install -y firefox
##ENV FIREFOX_VERSION 33.0
##RUN cd /usr/local && \
##wget http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/33.0/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 && \
##tar xvjf firefox-$FIREFOX_VERSION.tar.bz2 && \
##ln -s /usr/local/firefox/firefox /usr/bin/firefox




#========================================
# Add normal user with passwordless sudo
#========================================
## RUN sudo useradd seluser --shell /bin/bash --create-home \
##  && sudo usermod -a -G sudo seluser \
##  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

#====================================================================
# Script to run selenium standalone server for Chrome and/or Firefox
#====================================================================
## COPY ./bin/*.sh /opt/selenium/
## RUN  chmod +x /opt/selenium/*.sh


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