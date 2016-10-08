#!/bin/bash

# Check input params
help="Usage: sh mysql-install.sh [5.6|5.7 [your-new-root-password]]"
if [ "$#" -ge 3 ]; then
    echo $help
    exit 1
fi

# Force MySQL version if specified
if [ $# -ge 1 ]; then
	if [ $1 == '5.6' ]; then
		yum install -y yum-utils >> /dev/null
	    yum-config-manager --disable mysql57-community >> /dev/null
	    yum-config-manager --enable mysql56-community >> /dev/null
	elif [ $1 == '5.7' ]; then
		yum install -y yum-utils >> /dev/null
	    yum-config-manager --disable mysql56-community >> /dev/null
	    yum-config-manager --enable mysql57-community >> /dev/null
	else
	    echo $help
	    exit 1
	fi
    yum repolist all | grep mysql
fi

# Install
echo "Installing MySQL $1 ..."
yum install -y mysql-server

# Start service
systemctl start mysqld

# Secure
if [ "$#" -ne 2 ]; then
	echo "Installation of MySQL $1 finished but is not secure."
	exit 1
fi
pathSecureScript="/root/Downloads"  # IMPORTANT!! Fill this with your custom path
echo "Securing installation ..."
if [ $1 == '5.6' ]; then
	sh $pathSecureScript/mysql-secure.sh $2
elif [ $1 == '5.7' ]; then
	echo "Waiting to mysqld service to generate temporary password ..."
	sleep 7
	tempPass="$(grep 'temporary password' /var/log/mysqld.log | awk '{printf $NF}')"
	sh $pathSecureScript/mysql-secure.sh $tempPass $2	
fi

echo "Installation of MySQL $1 finished and is secure."

exit 0