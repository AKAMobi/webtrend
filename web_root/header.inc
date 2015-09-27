<?
use CGI ;
use DBI ;
use POSIX qw(strftime);   

#my $user_db_host = "zixia.net" ;
#my $user_db_user = "zixia" ;
#my $user_db_pass = "IamZixia!" ;

my $user_db_host = "sql.chinaren.net" ;
my $user_db_user = "zixia" ;
my $user_db_pass = "IamZixia!" ;

my $log_db_host = "news.chinaren.net" ;
my $log_db_user = "zixia" ;
my $log_db_pass = "IamZixia!" ;

my $query = new CGI ;

my $dbh ; # this is for user register info .
my $dbh_log ; # this is the log bd's dbh.

$dbh = DBI->connect ( "DBI:mysql:ChinaRen:$user_db_host", $user_db_user, $user_db_pass ) or die "user db connect error!" ;
$dbh_log = DBI->connect ( "DBI:mysql:web_log_db:$log_db_host", $log_db_user, $log_db_pass ) or die "web log db connect error!" ;

$filter = $query->param("filter") ;
$use_filter = $query->param("use_filter") ;

$remote_user = $ENV{'REMOTE_USER'} ;
$request_uri = $ENV{'REQUEST_URI'} ;

if ( 1 <= @{$allow_page{$remote_user}} ){
	$is_valid_user = 0 ;
#print "found valid user <br>" ;
	foreach ( @{$allow_page{$remote_user}} ){
		if ( $request_uri eq $_ ){
			$is_valid_user = 1 ;
			last ;
		}
	}
}elsif ( 1 <= @{$deny_page{$remote_user}} ){
#print "found deny_user<br>" ;
	$is_valid_user = 1 ;
	foreach ( @{$deny_page{$remote_user}} ){
		if ( $request_uri eq $_ ){
			$is_valid_user = 0 ;
			last ;
		}
	}
}else{
#print "no deny/allow user found<br>" ;
	$is_valid_user = 0 ;
}

if ( ($remote_user ne "logadm") && !$is_valid_user ){
	#print "<h1>user: $remote_user, uri: $request_uri</h1>" ;
	print "<h1><font color=red>SORRY, YOU HAVE NOT BEEN PERMIT TO VIEW THIS PAGE!</font></h1>" ;
	$dbh->disconnect() if $dbh ;
	$dbh_log->disconnect() if $dbh_log ;
	exit 0 ;
}
	

!>
<!--<h1>user: <?=$remote_user!>, uri: <?=$request_uri!></h1>-->
<div align="center">
  <h1><a href="/"><font color="#00CCCC">ChinaRen Web 分析系统</font></a></h1>
User: <font color=red><?=$remote_user!></font><br>
</div>
<div align="center"> 
  <p>
<table border=0>
<tr><td>
	<a href="/user/user.phtml">[注册用户数目分析]</a>
</td><td>
	<a href="/product/product.phtml">[各项产品PageView分析]</a>
</td><td>
	<a href="/session/session.phtml">[注册用户Session分析]</a>
</td></tr>
<tr><td>
	<a href="/ip_list/ip_list.phtml">[注册用户网段分析]</a>
</td><td>
	<a href="/ip_product/ip_product.phtml">[产品PageView网段分布]</a>
</td><td>
	<a href="/complex/complex.phtml">[综合PageView访问分析]</a>
</td></tr>
<tr><td>
	<a href="/online_user/online_user.phtml">[在线用户数目分析]</a>
</td><td>
	<a href="/ip_product/"></a>
</td><td>
	<a href="/"></a>
</td></tr>

</table>
  </p>
</div>

