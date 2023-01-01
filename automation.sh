#!/bin/bash

# Author of the Script: Zixiang Zhou 

# Project: Automation Project 

##################################################################################################
#	                          Task 2
##################################################################################################

# 1. Perform an update of the package details and the package list at the start of the script

sudo apt update -y
sleep 20


# 2. Check the existence of the apache2 package and in case the package is not installed, install it. 

pkg="apache2"

which $pkg > /dev/null 2>&1
if [ $? == 0 ]
then
echo "The $pkg has already been installed. "
else
echo "The $pkg has not yet been installed, now installing it"
sudo apt install $pkg -y
sleep 25 # Give 25 secs for the Apache2 package to be installed
fi

# 3. Ensure the apache2 service is running. 

servstat=$(sudo systemctl status apache2)

if [[ $servstat == *"active (running)"* ]]; then
  echo "Apache2 Service is running"
else
  echo "Apache2 Service is not running, now we start it"
  sudo systemctl start apache2
  sleep 2 # Give 2 sec for the Apache2 service to start
fi

# 4. Get the timestamp and Create a tar archive of apache2 access logs and error logs 
# that are present in the /var/log/apache2/ directory and place the tar into the /tmp/ directory.

myname="ZixiangZhou"
timestamp=$(date '+%d%m%Y-%H%M%S')
FileName=${myname}-httpd-logs-${timestamp}.tar

tar -cvf $FileName /var/log/apache2/

# Move this tar file into the /tmp/ directory

mv $FileName /tmp

# Move this tar file to the s3 bucket 

s3_bucket="upgrad-zixiangzhou"

aws s3 cp /tmp/$FileName s3://${s3_bucket}/$FileName




