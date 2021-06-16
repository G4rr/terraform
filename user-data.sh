#!/bin/bash
yum -y update
yum -y install httpd

sudo yum install git -y
cd; git clone https://github.com/G4rr/Final_project.git
sudo mv Final_project/* /var/www/html/

sudo service httpd start
chkconfig httpd on
