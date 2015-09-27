#!/bin/sh
if [ -f /opt/cron/Users.log ]
then

        ~zixia/WebTrend/online.pl < /opt/cron/Users.log
        if
                test $? -eq 0
        then
                cat /dev/null > /opt/cron/Users.log
	fi
fi
