#!bin/bash

sudo apt update -y
sudo apt-get install tomcat9 tomcat9-docs tomcat9-admin -y
sudo cp -r /usr/share/tomcat9-admin/* /var/lib/tomcat9/webapps/ -v 
