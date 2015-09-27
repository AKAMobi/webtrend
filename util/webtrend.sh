#!/bin/sh
bakfile=/tmp/oldlog/access_log_`date +%Y_%j_%H`_$$
cp -f /usr/local/apache/logs/access_log $bakfile
cat /dev/null > /var/log/apache/access_log
~zixia/WebTrend/log2db.pl < $bakfile
if
        test $? -eq 0
then
        gzip $bakfile
else
        cat $bakfile >> /var/log/apache/access_log
        rm -f $bakfile
	echo `date` webtrend failure. log resume succeed
fi


if [ -f /opt/cron/Users.log ]
then
	~zixia/WebTrend/online.pl < /opt/cron/Users.log
	if
        	test $? -eq 0
	then
        	cat /dev/null > /opt/cron/Users.log
fi
