#!/usr/bin/perl -w

#### zixia 's log format
#LogFormat "%a %v [%{%Y-%m-%d %T}t] %{Cookie}i \"%r\" %>s" common
#### Need config it in apache/conf/httpd.conf

use DBI ;

# mysql db host
$mysql_host = "news.chinaren.net" ;
$mysql_user = "zixia" ;
$mysql_pass = 'IamZixia!' ;

my %month_to_num = ( 'Jan' => '01', 'Feb' => '02', 'Mar' => '03',
                     'Apr' => '04', 'May' => '05', 'Jun' => '06',
                     'Jul' => '07', 'Aug' => '08', 'Sep' => '09',
                     'Oct' => '10', 'Nov' => '11', 'Dec' => '12');             

my @valid_log = ( "GET / ", "htm", "php", "jsp" ) ;
my @login = ( "GET /register.php3", 
	"GET /accept.php3", 
	"GET /setposition.php3", 
	"GET /login.php3" ) ;

my $login ;

my $global_last_product ;
my $global_last_request ;
my $global_last_time ;
$global_last_product='NONE' ;
$global_last_request="NONE" ;
$global_last_time=0 ;

my ( $valid_log_ok, $valid_log ) ;
my ($guser_id, $ghost_name, $gvisitor_ip, $gdate_time) ;

#close ( STDERR ) ;

my $dbh = DBI->connect("DBI:mysql:web_log_db:$mysql_host", $mysql_user, $mysql_pass ) or die "$DBI::errstr" ;
my $sth = $dbh->prepare ( <<_SQL_ ) or die "$DBI::errstr" ;
INSERT INTO access_log_tb ( user_id, visitor_ip, host_name, date_time ) 
values ( ?,?,?,? )
_SQL_

NEXT_LOG: while ( my $log = <> )
{
	chop $log ;

	next if ( $log =~ m#GET /checkmsg.php3 HTTP#i ) ;
	next if ( $log =~ m#GET /setposition.php3#i ) ;
	$valid_log_ok = 0 ;
	foreach $valid_log ( @valid_log ) {
		if ( $log=~m/$valid_log/i ){
			$valid_log_ok = 1 ;
			last ;
		}
	}
	next until $valid_log_ok ;
	$log =~ /\"(.+)\"/ ;
	$request = $1 ;
    ($guser_id, $ghost_name, $gvisitor_ip, $gdate_time) = old_log_anal ( $log ) ;
	if ( $ghost_name =~ /([^\.]+)\.chinaren.[^\.]+$/i ){
		$ghost_name = $1 ;
	}else{
		next ;
	}
	next until ( $gvisitor_ip && $ghost_name && $gdate_time ) ;
	next if ( $ghost_name =~ /^ad$/i ) ;
	$guser_id = '' until ( defined $guser_id ) ;
	next if ( &is_reload($ghost_name,$request,$gdate_time) ) ;
    $sth->execute ( $guser_id, $gvisitor_ip, $ghost_name, $gdate_time ) or die "$DBI::errstr" ;
    #print "$guser_id\t$ghost_name\t$gvisitor_ip\t$gdate_time\n" ;
}

$sth->finish ;
$dbh->disconnect ;

exit 0 ;

############################
sub old_log_anal
{
    local $str ;
    $str = $_[0] ;

    local ($user_id, $host_name, $visitor_ip, $date_time) ;

    if ( $str=~/CHINARENKEY/i ){
	#print STDERR "found cookie\n" ;
	$str =~ /CHINARENKEY=([^\%]+)\%5E/i ;
	$user_id = $1 ;
    }else{
	$user_id = "" ;
    }

    $str =~ /^([^ ]+) ([^ ]+)/ ;
    $visitor_ip = $1 ;
	$tmp_hostname = $2 ;
	$is_login = 0 ;
	foreach $login ( @login ) {
		if ( $str =~ /$login/i ){
			$is_login = 1;
		}
	}
    if ( $is_login ){
	$host_name = 'login.chinaren.net' ;
    }else{
   	$host_name = $tmp_hostname ;
    }	

    if ( !$visitor_ip ){
		#print STDERR "analyze ip error\n" ;
    }
	if ( !$host_name ){
		print STDERR "?? no VirtualHost? ???\n" ;
	}
	

    $str =~ /\[([^\]]+)\]/ ;
    $date_time = $1 ;
    if ( !$date_time ){
	print STDERR "analyze date_time error" ;
    }else{
#	$date_time =~ s# .+$## ;
#	$date_time =~ s#([^:]+):(.+)## ;
#	
#	local ($date, $time, @tmp) ;
#	$date = $1 ;
#	$time = $2 ;
#	@tmp = split ( "\/", $date ) ;
#	$tmp[1] = $month_to_num{$tmp[1]} ;
#	$date = "$tmp[2]-$tmp[1]-$tmp[0]" ;
#	$date_time = "$date $time" ;
    }
    ($user_id, $host_name, $visitor_ip, $date_time) ;
}
sub is_reload
{
	local ( $product,$crequest,$date_time ) = @_ ;
	local ( $sec ) ;
	$date_time =~ /:(\d+)$/ ;
	$sec = $1 or die "no sec found!" ;
	if ( $global_last_product eq $product &&
			$global_last_request eq $crequest){
		if ( 1 >= ($sec-$global_last_time) ){
			$global_last_time = $sec ;
			return 1 ;
		}
	}
	$global_last_product = $product ;
	$global_last_request = $crequest ;
	$global_last_time = $sec ;
	return 0 ;
}
