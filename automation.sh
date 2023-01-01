#!/bin/bash

# Author of the Script: Zixiang Zhou 

# Project: Automation Project 

# The task 2 part  has been validated and the execuation of all the operations is aligned with my expectation.
# The tar file can be found in S3 Bucket after running this script

# This script has addeded an additional feature to get the size of the tar file and create or append an inventory.html file

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

# Get the size of the tar file and save it to a variable (to be used for task 3)

sizeOfTar=$(wc --bytes $FileName | awk '{print $1}')

# Move this tar file into the /tmp/ directory

mv $FileName /tmp

# Move this tar file to the s3 bucket 

s3_bucket="upgrad-zixiangzhou"

aws s3 cp /tmp/$FileName s3://${s3_bucket}/$FileName

##################################################################################################
#	                          Task 3
##################################################################################################


# 5. Check the presense of the inventory.html file in /var/www/html/;
# If not found, we create it.

# Specify the filename to check in the designated Directory

File=/var/www/html/inventory.html

# Check if the file already exists, if not, create one with the header row using html table format. 
# if yes, append additional row to record a new entry in the inventory.html file

if [ -f "$File" ]; then
	echo "$File exists."
	echo "<table width="500" cellspacing="12"><tr><td align="middle">httpd-logs</td><td align="middle">${timestamp}</td><td align="left">tar</td><td align="middle">${sizeOfTar}</td></tr></table>" >>$File
else
	echo "$File does not exist now we create a file."
	sudo touch $File
	sudo chmod 777 $File
	echo "<table width="500" cellspacing="12"><tr><th>Log Type</th><th>Date Created</th><th>Type</th><th>Size</th></tr></table>" >>$File
	echo "<table width="500" cellspacing="12"><tr><td align="middle">httpd-logs</td><td align="middle">${timestamp}</td><td align="left">tar</td><td align="middle">${sizeOfTar}</td></tr></table>" >>$File
fi

# Upload the inventory log to the AWS S3 (Not Required)

aws s3 cp $File s3://${s3_bucket}/inventory.html


