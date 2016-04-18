#!/bin/sh
sudo rm -rf /usr/local/tomcat/webapps/*
sudo mv /usr/tmp/phit-web.war /usr/local/tomcat/webapps
sudo unzip /usr/local/tomcat/webapps/phit-web.war -d /usr/local/tomcat/webapps/phit-web
sudo rm -f phit-web.war
cd /usr/local/tomcat/bin
sudo sh startup.sh