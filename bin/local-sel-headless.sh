#!/usr/bin/env bash

sudo -E -i -u seluser \
    DOCKER_HOST_IP=$DOCKER_HOST_IP \
    /usr/local/lib/node_modules/protractor/bin/webdriver-manager start
    # java -jar /opt/selenium/selenium-server-standalone.jar -port $SELENIUM_PORT 2>&1 | tee $SELENIUM_LOG