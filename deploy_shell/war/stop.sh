#!/bin/sh
kill -9 $(ps -aef | grep tomcat/conf | grep -v grep | awk '{print $2}')
echo "phit-web has been stopped!"