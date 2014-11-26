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
RUN sudo apt-get install -y 
    x11-xkb-utils \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-scalable \ 
    xserver-xorg-core \
    dbus-x11 \
    libfontconfig1-dev \
    libxi6 \
    libgconf-2-4 

#=================
# Set Up the Selenium Standalone Server as a Service                           (7)
# Then place this start script into /etc/init.d/selenium:
#=================
ENV SELENIUM_VERSION_PRE 2.37
ENV SELENIUM_VERSION 2.37.0
RUN \
/usr/sbin/useradd -m -s /bin/bash -d /home/selenium selenium && \
mkdir /usr/local/share/selenium && \
cd /tmp && \
wget http://selenium.googlecode.com/files/selenium-server-standalone-$SELENIUM_VERSION.jar && \
chown -R selenium:selenium /usr/local/share/selenium && \
mv selenium-server-standalone-$SELENIUM_VERSION.jar /usr/local/share/selenium && \
chown selenium:selenium /usr/local/share/selenium && \

# Set up loggin directory for Selenium
mkdir /var/log/selenium && \
chown selenium:selenium /var/log/selenium

# Copy over Selenium service script
ADD /selenium/selenium /etc/init.d/selenium 
# Make sure the service is executable, owned by root, and updated
RUN \
chown root:root /etc/init.d/selenium && \ 
chmod a+x /etc/init.d/selenium && \
update-rc.d selenium defaults && \

# run 
webdriver-manager update --standalone


#==============
# Install Browsers                                                             (4)
#==============
#==================
# Chrome webdriver
#==================
ENV CHROME_DRIVER_VERSION 2.12
RUN cd /tmp \
&& wget --no-verbose -O chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
&& cd /usr/local/lib/node_modules/protractor/selenium \
&& rm -rf chromedriver \
&& unzip /tmp/chromedriver_linux64.zip \
