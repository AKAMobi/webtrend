#!/bin/sh

if      
        test `ps ax|grep optimize |grep "perl -w"|wc -l` -eq 0
then    
	~zixia/WebTrend/optimize.pl >> ~zixia/WebTrend/optimize.log 2>&1
fi

