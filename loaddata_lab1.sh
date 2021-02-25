#!/bin/bash  
sudo yum -y install mysql-server
sudo service mysqld start

sudo  mysql <<EOF

create user 'workshop'@'%' identified by '12345678';
GRANT ALL PRIVILEGES ON *.* TO 'workshop'@'%';  
FLUSH PRIVILEGES;
create database workshopdb;
use workshopdb;
source ./loaddata_lab1.sql;

EOF
exit;