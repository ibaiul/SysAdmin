#!/bin/bash

#
# Forked from https://gist.github.com/coderua/5592d95970038944d099
#
# Automate mysql secure installation for RedHat based systems
# 
#  - You can set a password for root accounts.
#  - You can remove root accounts that are accessible from outside the local host.
#  - You can remove anonymous-user accounts.
#  - You can remove the test database (which by default can be accessed by all users, even anonymous users), 
#    and privileges that permit anyone to access databases with names that start with test_. 
#  For details see documentation: http://dev.mysql.com/doc/refman/5.7/en/mysql-secure-installation.html
#
# Tested on CentOS 7 - MySQL 5.7.15
#
# Usage:
#  Setup mysql root password:  ./mysql_secure.sh 'your_new_root_password'
#  Change mysql root password: ./mysql_secure.sh 'your_old_root_password' 'your_new_root_password'"
#

# Delete package expect when script is done
# 0 - No; 
# 1 - Yes.
PURGE_EXPECT_WHEN_DONE=0

#
# Check the bash shell script is being run by root
#
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#
# Check input params
#
if [ -n "${1}" -a -z "${2}" ]; then
    # Setup root password
    CURRENT_MYSQL_PASSWORD=''
    NEW_MYSQL_PASSWORD="${1}"
elif [ -n "${1}" -a -n "${2}" ]; then
    # Change existens root password
    CURRENT_MYSQL_PASSWORD="${1}"
    NEW_MYSQL_PASSWORD="${2}"
else
    echo "Usage:"
    echo "  Setup mysql root password: ${0} 'your_new_root_password'"
    echo "  Change mysql root password: ${0} 'your_old_root_password' 'your_new_root_password'"
    exit 1
fi

#
# Check is expect package installed
#
yum list installed expect
if [ $? -ne 0 ]; then
    echo "Can't find expect. Trying to install ..."
    yum install -y expect
    status=$?
    if [ $status -ne 0 ]; then
    	echo "Unable to install expect. Status: $status. Exiting ..."
    	exit 1
    fi
fi

#
# Execution mysql_secure_installation
#
/usr/bin/expect << EOF

set timeout 3
spawn mysql_secure_installation

expect "Enter current password for root (enter for none):"
send "$CURRENT_MYSQL_PASSWORD\r"

expect "root password?"
send "y\r"

expect "New password:"
send "$NEW_MYSQL_PASSWORD\r"

expect "Re-enter new password:"
send "$NEW_MYSQL_PASSWORD\r"

expect "Remove anonymous users?"
send "y\r"

expect "Disallow root login remotely?"
send "y\r"

expect "Remove test database and access to it?"
send "y\r"

expect "Reload privilege tables now?"
send "y\r"

EOF

if [ "${PURGE_EXPECT_WHEN_DONE}" -eq 1 ]; then
    # Uninstalling expect package
    yum remove -y expect
fi

exit 0