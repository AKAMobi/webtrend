<hr>
<div align=right>
<a href='mailto:zixia@chinaren-inc.com'>zixia@ChinaRen Inc.</a> 1999, All rights reserved. 
</div>
<?
$dbh->disconnect() if $dbh ;
$dbh_log->disconnect() ;

open ( FD, ">>/opt/news/zixia/WebTrend/web_root/access.log" ) or die "open log file error" ;
$now_string = strftime "%Y年%m月%d日%H时%M分", localtime;
print FD "$now_string\t用户:$remote_user\t访问页面:$request_uri\t来自:$ENV{'REMOTE_ADDR'}\n" ;
close ( FD ) ;    
!>
