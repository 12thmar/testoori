FROM seid/node-chrome:2.44.0
MAINTAINER Seid Adem <seid.adem@gmail.com>

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

RUN npm install -g requirejs
RUN npm install -g grunt-cli
RUN npm install -g karma
RUN npm install -g request


#=================
# Install protractor 
#=================
RUN npm install -g protractor
#RUN webdriver-manager update
