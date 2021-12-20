#!/bin/bash
name="Manojkumar"
s3bucket="upgradmanojkumarg"
timeStamp=$(date '+%d%m%Y-%H%M%S')
fileName="$name-httpd-logs-$timeStamp.tar"

echo "Updating packages..."
apt update -y 
echo " "
apache_status=$(systemctl is-active apache2)
if [ "${apache_status}" != "active" ]
then
	dpkg --get-selections | grep -w apache2
	echo " "
	if [ $(echo $?) -ne 0 ]
	then
		echo "Apache2 Not installed."
		echo "Installing Apache2..."
		apt install apache2 -y
		systemctl enable apache2
		echo "Starting Apache2..."
		systemctl start apache2
		echo "Apache2 Status : $(systemctl is-active apache2 | tr '[:lower:]' '[:upper:]')"
	else
		echo "Starting Apache2..."
		systemctl start apache2
		echo "Apache2 Status : $(systemctl is-active apache2 | tr '[:lower:]' '[:upper:]')"
	fi
else
	echo "Apache2 Already UP and Running" 
	echo " "
fi

ls /var/log/apache2/*.log
if [ $(echo $?) = 0 ]
then
	echo "Taking backup of Apache log files"
	tar -cvf /tmp/${fileName} /var/log/apache2/*.log
	aws s3 cp /tmp/${fileName} s3://${s3bucket}/${fileName}
	echo " "
	if [ $(echo $?) != 0 ]
	then
		echo "${fileName} copy to S3 bucket $s3bucket : FAILED"
	else
		echo "${fileName} copy to S3 bucket $s3bucket : SUCCESS"
	fi
fi

