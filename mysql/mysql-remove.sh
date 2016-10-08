#!/bin/bash

# Check input params
if [ "$#" -ge 2 ] || [[ ! -z "$1" && "$1" != '-c' ]]; then
	echo "Usage: mysql-remove.sh [-c]"
	exit 1
fi

# Stop mysqld daemon
systemctl stop mysqld

# Uninstall
yum remove -y mysql-community-*

# Remove completely
if [ "$1" == '-c' ]; then
	echo "Uninstalling completely ..."
	rm -rf /usr/share/mysql
	rm -rf /var/lib/mysql
	rm -f /var/log/mysqld.log
	# This is already deleted in the remove process
	#rm -rf /etc/logrotate.d/mysql
	#rm -rf /usr/bin/mysql
	#rm -rf /usr/lib64/mysql
	echo "Uninstalled completely"
fi

exit 0