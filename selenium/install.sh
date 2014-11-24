#!/bin/bash

# Copy over service script
cp /srv/salt/selenium/xvfb /etc/init.d/xvfb

# Make sure the service is executable, owned by root, and updated
chown root:root /etc/init.d/xvfb
chmod a+x /etc/init.d/xvfb
update-rc.d /etc/init.d/xvfb defaults

# Make Selenium Standalone run as service with own user
/usr/sbin/useradd -m -s /bin/bash -d /home/selenium selenium
mkdir -p /usr/local/share/selenium
wget http://selenium.googlecode.com/files/selenium-server-standalone-2.37.0.jar
mv selenium-server-standalone-2.37.0.jar /usr/local/share/selenium
chown -R selenium:selenium /usr/local/share/selenium

# Set up loggin directory for Selenium
mkdir /var/log/selenium
chown selenium:selenium /var/log/selenium

# Copy over Selenium service script
cp /srv/salt/selenium/selenium /etc/init.d/selenium

# Make sure the service is executable, owned by root, and updated
chown root:root /etc/init.d/selenium
chmod a+x /etc/init.d/selenium
update-rc.d /etc/init.d/selenium defaults

# PhantomJS log file
touch /phantomjsdriver.log
chmod 666 /phantomjsdriver.log