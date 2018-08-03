#!/bin/bash
# Script to check replication status and send notification email if it has failed.
# Created by: Joseph Crutsinger
# Date: 09/30/2013
# Modified: 07/20/2018
# Crontab: */10 * * * * /usr/local/bin/repli_check.sh >/dev/null 2>&1

check=`mysql -ureplica -e "show slave status\G" | grep Seconds_Behind_Master | awk '{print $2'}`
threshold=150
hostname=`/bin/hostname`

if [[ "$check" -gt "$threshold" ]];  then
echo "ALERT ON $hostname, SLAVE REPLICATION IS BEHIND MASTER BY $check. CONTACT DBA FOR RESOLUTION" | mail -s "$hostname SLAVE REPLICATION IS BEHIND MASTER" jcrutsinger@darthlinux.com
fi

check2=`mysql -ureplica -e "show slave status\G;" | grep Slave_SQL_Running | head -1 | awk '{print $2}'`

if [[ "$check2" == "Yes" ]]; then
exit 0;
else
echo "$hostname: Slave SQL RUNNING is DOWN, CURRENT STATUS IS $check2 - CONTACT DBA FOR RESOLUTION" | mail -s "$hostname: SLAVE SQL RUNNING IS DOWN, CONTACT DBA FOR RESOLUTION" jcrutsinger@darthlinux.com
fi

check3=`mysql -ureplica -e "show slave status\G;" | grep Slave_IO_Running | awk '{print $2}'`

if [[ "$check3" == "Yes" ]]; then
exit 0;
else
echo "$hostname Slave IO is NOT RUNNING, CURRENT STATUS IS $check3 - CONTACT DBA FOR RESOLUTION" | mail -s "$hostname: SLAVE IO IS NOT RUNNING, CONTACT DBA FOR RESOLUTION" jcrutsinger@darthlinux.com
fi
