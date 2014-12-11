FROM ubuntu:14.04
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
    sudo \
  && rm -rf /var/lib/apt/lists/*

#==========
# Selenium
#==========
RUN  mkdir -p /opt/selenium \
  && wget --no-verbose http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar -O /opt/selenium/selenium-server-standalone.jar

#========================================
# Add normal user with passwordless sudo
#========================================
RUN sudo useradd seluser --shell /bin/bash --create-home && \
    sudo usermod -a -G sudo seluser && \
    echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo 'seluser:secret' | chpasswd

#========================
# Selenium Configuration
#========================
COPY configs/hub-config.json /opt/selenium/config.json

EXPOSE 4444

USER seluser

CMD ["java", "-jar", "/opt/selenium/selenium-server-standalone.jar", "-role", "hub", "-hubConfig", "/opt/selenium/config.json"]